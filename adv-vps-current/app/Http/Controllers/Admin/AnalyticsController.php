<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\MarketInsight;
use App\Models\Product;
use App\Models\Province;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    public function index()
    {
        $nowMonth       = now()->month;
        $defaultFiscalYear = in_array($nowMonth, [1, 2, 3]) ? now()->year - 1 : now()->year;

        return inertia('admin/analytics/Index', [
            'products'     => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
            'distributors' => Customer::where('type', Customer::Type_Distributor)->orderBy('name')->get(['id', 'name']),
            'default_fiscal_year' => $defaultFiscalYear,
        ]);
    }

    public function salesChart(Request $request)
    {
        $fy         = (int) $request->get('fiscal_year', now()->year);
        $compareFyA = (int) $request->get('compare_fy_a', $fy);
        $compareFyB = (int) $request->get('compare_fy_b', $fy - 1);
        $month      = $request->get('month');       // optional (1-12)
        $distributorId = $request->get('distributor_id');

        $applyDistributorScope = function ($query) {
            // Samakan dengan scope menu Penjualan utama:
            // 1) source_from=distributor (termasuk histori sale_type=retailer yang memang berasal dari distributor)
            // 2) fallback data legacy sale_type=distributor tanpa source_from
            $query->where(function ($scope) {
                $scope->where('sales.source_from', Sale::Source_Distributor)
                    ->orWhere(function ($legacyScope) {
                        $legacyScope->where('sales.sale_type', Sale::Type_Distributor)
                            ->where(function ($legacySource) {
                                $legacySource->whereNull('sales.source_from')
                                    ->orWhere('sales.source_from', '');
                            });
                    });

            });
        };

        $applyExcludeBsRetailerScope = function ($query) {
            $query->where(function ($scope) {
                $scope->where('sales.sale_type', Sale::Type_Distributor)
                    ->orWhere(function ($retailerScope) {
                        $retailerScope->where('sales.sale_type', Sale::Type_Retailer)
                                ->where(function ($creatorScope) {
                                    $creatorScope->whereNull('sales.created_by_uid')
                                        ->orWhereNotIn('sales.created_by_uid', function ($sub) {
                                            $sub->select('id')
                                                ->from('users')
                                                ->whereIn('role', [User::Role_BS, 'field_officer']);
                                        });
                            });
                    });
            });
        };

        // ── Date range for fiscal year ──
        $fyStart = Carbon::createFromDate($fy, 4, 1)->startOfDay();
        $fyEnd   = Carbon::createFromDate($fy + 1, 3, 31)->endOfDay();
        $amountExpr = 'sale_items.quantity * COALESCE(NULLIF(sale_items.price, 0), products.price_1, products.price_2, 0)';

        $baseQuery = Sale::whereBetween('date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released);
        $applyDistributorScope($baseQuery);
        $applyExcludeBsRetailerScope($baseQuery);
        $baseQuery->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });
        if ($distributorId) $baseQuery->where('distributor_id', $distributorId);
        if ($month)         $baseQuery->whereMonth('date', $month);

        // ── Summary ──
        $totalSales = (float) ((clone $baseQuery)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("COALESCE(SUM({$amountExpr}), 0) as total_amount")
            ->value('total_amount'));
        $totalTransactions = (clone $baseQuery)->count();
        $avgPerTransaction = $totalTransactions > 0 ? round($totalSales / $totalTransactions, 0) : 0;

        $pendingPoQuery = Sale::whereBetween('date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Pending);
        $applyDistributorScope($pendingPoQuery);
        $applyExcludeBsRetailerScope($pendingPoQuery);
        $pendingPoQuery->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });
        if ($distributorId) {
            $pendingPoQuery->where('distributor_id', $distributorId);
        }
        if ($month) {
            $pendingPoQuery->whereMonth('date', $month);
        }
        $pendingPoCount = (clone $pendingPoQuery)->count();

        // ── Market size & market share overview ──
        $actualTotalQty = (float) ((clone $baseQuery)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->selectRaw('COALESCE(SUM(sale_items.quantity), 0) as total_qty')
            ->value('total_qty'));

        $marketQuery = Sale::whereBetween('date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released);
        $applyDistributorScope($marketQuery);
        $applyExcludeBsRetailerScope($marketQuery);
        $marketQuery->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });
        if ($month) {
            $marketQuery->whereMonth('date', $month);
        }

        $salesMarketSizeQty = (float) ((clone $marketQuery)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->selectRaw('COALESCE(SUM(sale_items.quantity), 0) as market_size_qty')
            ->value('market_size_qty'));

        $salesMarketSizeValue = (float) ((clone $marketQuery)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("COALESCE(SUM({$amountExpr}), 0) as market_size_value")
            ->value('market_size_value'));

        $insightQuery = MarketInsight::query()
            ->where('fiscal_year', $fy);

        $selectedInsightRows = collect();
        if ($month) {
            $selectedInsightRows = (clone $insightQuery)
                ->where('month', (int) $month)
                ->get(['market_size_value', 'market_share_percent']);

            if ($selectedInsightRows->isEmpty()) {
                $selectedInsightRows = (clone $insightQuery)
                    ->whereNull('month')
                    ->get(['market_size_value', 'market_share_percent']);
            }
        } else {
            $annualRows = (clone $insightQuery)
                ->whereNull('month')
                ->get(['market_size_value', 'market_share_percent']);

            $selectedInsightRows = $annualRows->isNotEmpty()
                ? $annualRows
                : (clone $insightQuery)->get(['market_size_value', 'market_share_percent']);
        }

        $insightMarketSizeValue = (float) $selectedInsightRows->sum('market_size_value');
        $insightShareAvg = $selectedInsightRows->count() > 0
            ? (float) $selectedInsightRows->avg('market_share_percent')
            : null;

        $hasInsightMarket = $insightMarketSizeValue > 0;
        $marketSizeQty = $salesMarketSizeQty;
        $marketSizeValue = $hasInsightMarket ? $insightMarketSizeValue : $salesMarketSizeValue;
        $marketSource = $hasInsightMarket ? 'market_insight' : 'sales_actual';

        $marketGapValue = max($marketSizeValue - $totalSales, 0);
        $marketSharePercent = null;
        if ($marketSizeValue > 0) {
            $marketSharePercent = (!$distributorId && $hasInsightMarket && $insightShareAvg !== null)
                ? round($insightShareAvg, 2)
                : round(($totalSales / $marketSizeValue) * 100, 2);
        }

        // ── Monthly trend (Apr → Mar) ──
        $months     = [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3];
        $monthLabels = [];
        $monthly    = [];

        foreach ($months as $m) {
            $calYear = in_array($m, [1, 2, 3]) ? $fy + 1 : $fy;
            $label   = Carbon::createFromDate($calYear, $m, 1)->translatedFormat('M Y');
            $monthLabels[] = $label;

            $q = (clone $baseQuery)->whereMonth('date', $m)->whereYear('date', $calYear);
            $monthTotal = (float) ((clone $q)
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
                ->selectRaw("COALESCE(SUM({$amountExpr}), 0) as total_amount")
                ->value('total_amount'));
            $monthly[] = [
                'label' => $label,
                'total' => $monthTotal,
                'count' => $q->count(),
            ];
        }

        // ── Monthly market share trend (Apr -> Mar) ──
        $marketSizeMonthlyMap = collect();
        $marketShareInputMonthlyMap = collect();

        if ($hasInsightMarket) {
            $insightMonthlyRows = MarketInsight::query()
                ->where('fiscal_year', $fy)
                ->whereNotNull('month')
                ->selectRaw('month as m, COALESCE(SUM(market_size_value), 0) as total, AVG(market_share_percent) as avg_share')
                ->groupBy('month')
                ->get();

            $marketSizeMonthlyMap = $insightMonthlyRows->mapWithKeys(fn($row) => [((int) $row->m) => (float) $row->total]);
            $marketShareInputMonthlyMap = $insightMonthlyRows->mapWithKeys(fn($row) => [((int) $row->m) => $row->avg_share === null ? null : (float) $row->avg_share]);

            $insightAnnualRows = MarketInsight::query()
                ->where('fiscal_year', $fy)
                ->whereNull('month')
                ->get(['market_size_value', 'market_share_percent']);

            if ($marketSizeMonthlyMap->isEmpty() && $insightAnnualRows->isNotEmpty()) {
                $annualTotal = (float) $insightAnnualRows->sum('market_size_value');
                $annualShare = (float) $insightAnnualRows->avg('market_share_percent');
                foreach ($months as $m) {
                    $marketSizeMonthlyMap->put($m, $annualTotal / 12);
                    $marketShareInputMonthlyMap->put($m, $annualShare);
                }
            }
        }

        if (!$hasInsightMarket) {
            $marketSizeMonthlyMap = (clone $marketQuery)
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
                ->selectRaw("YEAR(sales.date) as y, MONTH(sales.date) as m, COALESCE(SUM({$amountExpr}), 0) as total")
                ->groupBy('y', 'm')
                ->get()
                ->mapWithKeys(fn($row) => [((int) $row->y) . '-' . ((int) $row->m) => (float) $row->total]);
        }

        $marketShareMonthly = [];
        foreach ($months as $idx => $m) {
            $calYear = in_array($m, [1, 2, 3], true) ? $fy + 1 : $fy;
            $marketSizeMonthValue = $hasInsightMarket
                ? (float) ($marketSizeMonthlyMap->get($m, 0))
                : (float) ($marketSizeMonthlyMap->get($calYear . '-' . $m, 0));
            $actualMonthValue = (float) ($monthly[$idx]['total'] ?? 0);
            $inputShare = $hasInsightMarket ? $marketShareInputMonthlyMap->get($m) : null;
            $share = null;
            if ($marketSizeMonthValue > 0) {
                $share = (!$distributorId && $hasInsightMarket && $inputShare !== null)
                    ? round((float) $inputShare, 2)
                    : round(($actualMonthValue / $marketSizeMonthValue) * 100, 2);
            }

            $marketShareMonthly[] = [
                'label' => $monthLabels[$idx] ?? '',
                'actual_value' => $actualMonthValue,
                'market_size_value' => $marketSizeMonthValue,
                'share_percent' => $share,
            ];
        }

        // ── Distributor FY comparison (Current FY vs Previous FY) ──
        $compareAFyStart = Carbon::createFromDate($compareFyA, 4, 1)->startOfDay();
        $compareAFyEnd   = Carbon::createFromDate($compareFyA + 1, 3, 31)->endOfDay();
        $compareBFyStart = Carbon::createFromDate($compareFyB, 4, 1)->startOfDay();
        $compareBFyEnd   = Carbon::createFromDate($compareFyB + 1, 3, 31)->endOfDay();

        $distCurrentQ = Sale::query()
            ->whereBetween('date', [$compareAFyStart, $compareAFyEnd])
            ->where('sales.status', Sale::Status_Released)
            ;
        $applyDistributorScope($distCurrentQ);
        $applyExcludeBsRetailerScope($distCurrentQ);
        $distCurrentQ->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });

        $distPrevQ = Sale::query()
            ->whereBetween('date', [$compareBFyStart, $compareBFyEnd])
            ->where('sales.status', Sale::Status_Released)
            ;
        $applyDistributorScope($distPrevQ);
        $applyExcludeBsRetailerScope($distPrevQ);
        $distPrevQ->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });

        if ($distributorId) {
            $distCurrentQ->where('distributor_id', $distributorId);
            $distPrevQ->where('distributor_id', $distributorId);
        }

        $distCurrentMap = (clone $distCurrentQ)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("YEAR(sales.date) as y, MONTH(sales.date) as m, COALESCE(SUM({$amountExpr}), 0) as total")
            ->groupBy('y', 'm')
            ->get()
            ->mapWithKeys(fn($row) => [((int) $row->y) . '-' . ((int) $row->m) => (float) $row->total]);

        $distPrevMap = (clone $distPrevQ)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("YEAR(sales.date) as y, MONTH(sales.date) as m, COALESCE(SUM({$amountExpr}), 0) as total")
            ->groupBy('y', 'm')
            ->get()
            ->mapWithKeys(fn($row) => [((int) $row->y) . '-' . ((int) $row->m) => (float) $row->total]);

        $distCurrentMonthly = [];
        $distPrevMonthly = [];
        $distDeltaMonthly = [];
        $distGrowthMonthly = [];
        $compareMonths = [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3];
        $monthNameMap = [
            1 => 'Januari',
            2 => 'Februari',
            3 => 'Maret',
            4 => 'April',
            5 => 'Mei',
            6 => 'Juni',
            7 => 'Juli',
            8 => 'Agustus',
            9 => 'September',
            10 => 'Oktober',
            11 => 'November',
            12 => 'Desember',
        ];
        $compareLabels = [];

        foreach ($compareMonths as $m) {
            $currentYearForMonth = in_array($m, [1, 2, 3], true) ? $compareFyA + 1 : $compareFyA;
            $prevYearForMonth = in_array($m, [1, 2, 3], true) ? $compareFyB + 1 : $compareFyB;

            $currentVal = (float) ($distCurrentMap->get($currentYearForMonth . '-' . $m, 0));
            $prevVal = (float) ($distPrevMap->get($prevYearForMonth . '-' . $m, 0));
            $deltaVal = $currentVal - $prevVal;
            $growthVal = $prevVal > 0 ? round((($currentVal - $prevVal) / $prevVal) * 100, 2) : null;

            $distCurrentMonthly[] = $currentVal;
            $distPrevMonthly[] = $prevVal;
            $distDeltaMonthly[] = $deltaVal;
            $distGrowthMonthly[] = $growthVal;
            $compareLabels[] = $monthNameMap[$m] ?? (string) $m;
        }

        $distCurrentTotal = (float) array_sum($distCurrentMonthly);
        $distPrevTotal = (float) array_sum($distPrevMonthly);
        $distTotalGrowth = $distPrevTotal > 0 ? round((($distCurrentTotal - $distPrevTotal) / $distPrevTotal) * 100, 2) : null;

        $distCurrentAvgMonthly = round($distCurrentTotal / 12, 2);
        $distPrevAvgMonthly = round($distPrevTotal / 12, 2);
        $distAvgGrowth = $distPrevAvgMonthly > 0
            ? round((($distCurrentAvgMonthly - $distPrevAvgMonthly) / $distPrevAvgMonthly) * 100, 2)
            : null;

        // ── Sales by product ──
        $byProductQ = SaleItem::join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->join('products', 'sale_items.product_id', '=', 'products.id')
            ->whereBetween('sales.date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->selectRaw("products.name, COALESCE(SUM({$amountExpr}), 0) as total, COALESCE(SUM(sale_items.quantity), 0) as qty");

        $applyDistributorScope($byProductQ);
        $applyExcludeBsRetailerScope($byProductQ);
        if ($distributorId) $byProductQ->where('sales.distributor_id', $distributorId);
        if ($month)         $byProductQ->whereMonth('sales.date', $month);

        $byProduct = $byProductQ->groupBy('sale_items.product_id', 'products.name')
            ->orderByDesc('total')
            ->limit(10)
            ->get()
            ->map(fn($r) => ['name' => $r->name, 'total' => (float) $r->total, 'qty' => (float) $r->qty]);

        // ── Market share by product ──
        $actualByProductRows = SaleItem::query()
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->join('products', 'sale_items.product_id', '=', 'products.id')
            ->whereBetween('sales.date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->selectRaw("sale_items.product_id, products.name, COALESCE(SUM({$amountExpr}), 0) as actual_value");

        $applyDistributorScope($actualByProductRows);
        $applyExcludeBsRetailerScope($actualByProductRows);
        if ($distributorId) {
            $actualByProductRows->where('sales.distributor_id', $distributorId);
        }
        if ($month) {
            $actualByProductRows->whereMonth('sales.date', $month);
        }

        $actualByProduct = $actualByProductRows
            ->groupBy('sale_items.product_id', 'products.name')
            ->get()
            ->keyBy('product_id');

        $marketByProductRows = SaleItem::query()
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->join('products', 'sale_items.product_id', '=', 'products.id')
            ->whereBetween('sales.date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->selectRaw("sale_items.product_id, products.name, COALESCE(SUM({$amountExpr}), 0) as market_size_value");

        $applyDistributorScope($marketByProductRows);
        $applyExcludeBsRetailerScope($marketByProductRows);
        if ($month) {
            $marketByProductRows->whereMonth('sales.date', $month);
        }

        $marketByProduct = $marketByProductRows
            ->groupBy('sale_items.product_id', 'products.name')
            ->get()
            ->keyBy('product_id');

        $marketByProductTotal = (float) $marketByProduct->sum(fn($row) => (float) ($row->market_size_value ?? 0));
        $productScaleFactor = ($hasInsightMarket && !$distributorId && $marketByProductTotal > 0)
            ? ($marketSizeValue / $marketByProductTotal)
            : 1;
        $isProductMarketEstimated = ($hasInsightMarket && !$distributorId && $marketByProductTotal > 0);

        $productIds = $actualByProduct->keys()->merge($marketByProduct->keys())->unique()->values();
        $marketShareByProduct = collect();

        foreach ($productIds as $productId) {
            $actualProductRow = $actualByProduct->get($productId);
            $marketProductRow = $marketByProduct->get($productId);

            $actualValue = (float) ($actualProductRow->actual_value ?? 0);
            $marketSizeProductValue = round((float) ($marketProductRow->market_size_value ?? 0) * $productScaleFactor, 2);
            $productName = (string) ($actualProductRow->name ?? $marketProductRow->name ?? '-');

            $marketShareByProduct->push([
                'product_id' => (int) $productId,
                'name' => $productName,
                'actual_value' => $actualValue,
                'market_size_value' => $marketSizeProductValue,
                'share_percent' => $marketSizeProductValue > 0
                    ? round(($actualValue / $marketSizeProductValue) * 100, 2)
                    : null,
                'gap_value' => max($marketSizeProductValue - $actualValue, 0),
            ]);
        }

        $marketShareByProduct = $marketShareByProduct
            ->sortByDesc('market_size_value')
            ->take(10)
            ->values();

        // ── Top distributors ──
        $byDistQ = Sale::with('distributor:id,name')
            ->whereBetween('date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->whereExists(function ($sub) {
                $sub->selectRaw('1')
                    ->from('sale_items as si')
                    ->whereColumn('si.sale_id', 'sales.id')
                    ->where('si.quantity', '>', 0);
            })
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("sales.distributor_id as distributor_id, COALESCE(SUM({$amountExpr}), 0) as total, COUNT(DISTINCT sales.id) as count");

        $applyDistributorScope($byDistQ);
        $applyExcludeBsRetailerScope($byDistQ);
        if ($distributorId) $byDistQ->where('distributor_id', $distributorId);
        if ($month)         $byDistQ->whereMonth('date', $month);

        $byDistributor = $byDistQ->groupBy('distributor_id')
            ->orderByDesc('total')
            ->limit(10)
            ->get()
            ->map(fn($r) => [
                'name'  => $r->distributor?->name ?? '-',
                'total' => (float) $r->total,
                'count' => (int) $r->count,
            ]);

        // ── By region (province) ──
        $byRegionQ = Sale::join('provinces', 'sales.province_id', '=', 'provinces.id')
            ->whereBetween('sales.date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->whereExists(function ($sub) {
                $sub->selectRaw('1')
                    ->from('sale_items as si')
                    ->whereColumn('si.sale_id', 'sales.id')
                    ->where('si.quantity', '>', 0);
            })
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
            ->selectRaw("provinces.name, COALESCE(SUM({$amountExpr}), 0) as total, COUNT(DISTINCT sales.id) as count");

        $applyDistributorScope($byRegionQ);
        $applyExcludeBsRetailerScope($byRegionQ);
        if ($distributorId) $byRegionQ->where('sales.distributor_id', $distributorId);
        if ($month)         $byRegionQ->whereMonth('sales.date', $month);

        $byRegion = $byRegionQ->groupBy('sales.province_id', 'provinces.name')
            ->orderByDesc('total')
            ->limit(10)
            ->get()
            ->map(fn($r) => ['name' => $r->name, 'total' => (float) $r->total, 'count' => (int) $r->count]);

        return response()->json([
            'summary' => [
                'total_sales'          => (float) $totalSales,
                'total_transactions'   => (int) $totalTransactions,
                'avg_per_transaction'  => (float) $avgPerTransaction,
                'pending_po_count'     => (int) $pendingPoCount,
            ],
            'market_overview' => [
                'market_size_qty' => $marketSizeQty,
                'market_size_value' => $marketSizeValue,
                'actual_sales_value' => (float) $totalSales,
                'actual_sales_qty' => $actualTotalQty,
                'market_gap_value' => $marketGapValue,
                'market_share_percent' => $marketSharePercent,
                'market_source' => $marketSource,
            ],
            'market_share_monthly' => $marketShareMonthly,
            'market_share_by_product' => $marketShareByProduct,
            'market_product_meta' => [
                'is_estimated' => $isProductMarketEstimated,
                'scale_factor' => round((float) $productScaleFactor, 6),
                'base_market_total' => (float) $marketByProductTotal,
                'target_market_total' => (float) $marketSizeValue,
            ],
            'monthly'         => $monthly,
            'by_product'      => $byProduct,
            'by_distributor'  => $byDistributor,
            'by_region'       => $byRegion,
            'fy_compare'      => [
                'fy_current' => $compareFyA,
                'fy_previous' => $compareFyB,
                'labels' => $compareLabels,
                'current_monthly' => $distCurrentMonthly,
                'previous_monthly' => $distPrevMonthly,
                'delta_monthly' => $distDeltaMonthly,
                'growth_monthly' => $distGrowthMonthly,
                'current_total' => $distCurrentTotal,
                'previous_total' => $distPrevTotal,
                'total_growth_percent' => $distTotalGrowth,
                'current_avg_monthly' => $distCurrentAvgMonthly,
                'previous_avg_monthly' => $distPrevAvgMonthly,
                'avg_growth_percent' => $distAvgGrowth,
            ],
        ]);
    }

    public function pendingPo(Request $request)
    {
        $fy = (int) $request->get('fiscal_year', now()->year);
        $month = $request->get('month');
        $distributorId = $request->get('distributor_id');

        $applyDistributorScope = function ($query) {
            $query->where(function ($scope) {
                $scope->where('sales.source_from', Sale::Source_Distributor)
                    ->orWhere(function ($legacyScope) {
                        $legacyScope->where('sales.sale_type', Sale::Type_Distributor)
                            ->where(function ($legacySource) {
                                $legacySource->whereNull('sales.source_from')
                                    ->orWhere('sales.source_from', '');
                            });
                    });
            });
        };

        $applyExcludeBsRetailerScope = function ($query) {
            $query->where(function ($scope) {
                $scope->where('sales.sale_type', Sale::Type_Distributor)
                    ->orWhere(function ($retailerScope) {
                        $retailerScope->where('sales.sale_type', Sale::Type_Retailer)
                            ->where(function ($creatorScope) {
                                $creatorScope->whereNull('sales.created_by_uid')
                                    ->orWhereNotIn('sales.created_by_uid', function ($sub) {
                                        $sub->select('id')
                                            ->from('users')
                                            ->whereIn('role', [User::Role_BS, 'field_officer']);
                                    });
                            });
                    });
            });
        };

        $fyStart = Carbon::createFromDate($fy, 4, 1)->startOfDay();
        $fyEnd = Carbon::createFromDate($fy + 1, 3, 31)->endOfDay();

        $q = Sale::with([
            'distributor:id,name',
            'retailer:id,name,type',
            'created_by_user:id,name',
            'items:id,sale_id,product_id,quantity,unit',
            'items.product:id,name',
        ])
            ->whereBetween('date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Pending)
            ->whereExists(function ($sub) {
                $sub->selectRaw('1')
                    ->from('sale_items as si')
                    ->whereColumn('si.sale_id', 'sales.id')
                    ->where('si.quantity', '>', 0);
            });

        $applyDistributorScope($q);
        $applyExcludeBsRetailerScope($q);

        if ($distributorId) {
            $q->where('distributor_id', $distributorId);
        }
        if ($month) {
            $q->whereMonth('date', $month);
        }

        $rows = $q->orderByDesc('date')
            ->orderByDesc('id')
            ->limit(300)
            ->get();

        return response()->json([
            'total_rows' => (int) $rows->count(),
            'rows' => $rows,
        ]);
    }

}
