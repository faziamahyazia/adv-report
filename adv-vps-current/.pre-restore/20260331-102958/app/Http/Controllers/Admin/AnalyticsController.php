<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Product;
use App\Models\Province;
use App\Models\Sale;
use App\Models\SaleItem;
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
        $saleType   = $request->get('sale_type');   // optional: 'retailer'|'distributor'
        $distributorId = $request->get('distributor_id');

        // ── Date range for fiscal year ──
        $fyStart = Carbon::createFromDate($fy, 4, 1)->startOfDay();
        $fyEnd   = Carbon::createFromDate($fy + 1, 3, 31)->endOfDay();

        $baseQuery = Sale::whereBetween('date', [$fyStart, $fyEnd]);
        if ($saleType)     $baseQuery->where('sale_type', $saleType);
        if ($distributorId) $baseQuery->where('distributor_id', $distributorId);
        if ($month)         $baseQuery->whereMonth('date', $month);

        // ── Summary ──
        $totalSales       = (clone $baseQuery)->sum('total_amount');
        $totalTransactions = (clone $baseQuery)->count();
        $avgPerTransaction = $totalTransactions > 0 ? round($totalSales / $totalTransactions, 0) : 0;

        // ── Monthly trend (Apr → Mar) ──
        $months     = [4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3];
        $monthLabels = [];
        $monthly    = [];

        foreach ($months as $m) {
            $calYear = in_array($m, [1, 2, 3]) ? $fy + 1 : $fy;
            $label   = Carbon::createFromDate($calYear, $m, 1)->translatedFormat('M Y');
            $monthLabels[] = $label;

            $q = (clone $baseQuery)->whereMonth('date', $m)->whereYear('date', $calYear);
            $monthly[] = [
                'label' => $label,
                'total' => (float) $q->sum('total_amount'),
                'count' => $q->count(),
            ];
        }

        // ── Distributor FY comparison (Current FY vs Previous FY) ──
        $compareAFyStart = Carbon::createFromDate($compareFyA, 4, 1)->startOfDay();
        $compareAFyEnd   = Carbon::createFromDate($compareFyA + 1, 3, 31)->endOfDay();
        $compareBFyStart = Carbon::createFromDate($compareFyB, 4, 1)->startOfDay();
        $compareBFyEnd   = Carbon::createFromDate($compareFyB + 1, 3, 31)->endOfDay();

        $distCurrentQ = Sale::query()
            ->whereBetween('date', [$compareAFyStart, $compareAFyEnd])
            ;

        $distPrevQ = Sale::query()
            ->whereBetween('date', [$compareBFyStart, $compareBFyEnd])
            ;

        if ($saleType) {
            $distCurrentQ->where('sale_type', $saleType);
            $distPrevQ->where('sale_type', $saleType);
        }

        if ($distributorId) {
            $distCurrentQ->where('distributor_id', $distributorId);
            $distPrevQ->where('distributor_id', $distributorId);
        }

        $distCurrentMap = (clone $distCurrentQ)
            ->selectRaw('YEAR(date) as y, MONTH(date) as m, SUM(total_amount) as total')
            ->groupBy('y', 'm')
            ->get()
            ->mapWithKeys(fn($row) => [((int) $row->y) . '-' . ((int) $row->m) => (float) $row->total]);

        $distPrevMap = (clone $distPrevQ)
            ->selectRaw('YEAR(date) as y, MONTH(date) as m, SUM(total_amount) as total')
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
            ->selectRaw('products.name, SUM(sale_items.subtotal) as total, SUM(sale_items.quantity) as qty');

        if ($saleType)     $byProductQ->where('sales.sale_type', $saleType);
        if ($distributorId) $byProductQ->where('sales.distributor_id', $distributorId);
        if ($month)         $byProductQ->whereMonth('sales.date', $month);

        $byProduct = $byProductQ->groupBy('sale_items.product_id', 'products.name')
            ->orderByDesc('total')
            ->limit(10)
            ->get()
            ->map(fn($r) => ['name' => $r->name, 'total' => (float) $r->total, 'qty' => (float) $r->qty]);

        // ── Top distributors ──
        $byDistQ = Sale::with('distributor:id,name')
            ->whereBetween('date', [$fyStart, $fyEnd])
            ->selectRaw('distributor_id, SUM(total_amount) as total, COUNT(id) as count');

        if ($saleType)     $byDistQ->where('sale_type', $saleType);
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
            ->selectRaw('provinces.name, SUM(sales.total_amount) as total, COUNT(sales.id) as count');

        if ($saleType)     $byRegionQ->where('sales.sale_type', $saleType);
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
}
