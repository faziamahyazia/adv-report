<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\MarketInsight;
use App\Models\Product;
use App\Models\Province;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MarketInsightController extends Controller
{
    public function index()
    {
        $user = request()->user();
        $nowMonth = now()->month;
        $defaultFiscalYear = in_array($nowMonth, [1, 2, 3], true) ? now()->year - 1 : now()->year;

        $districtQuery = District::query()
            ->with('province:id,name')
            ->orderBy('name');

        if ($user->role === User::Role_BS) {
            $districtIds = $user->districts()->pluck('districts.id');
            if ($districtIds->isEmpty()) {
                $districtIds = $this->getWestJavaDistrictIds();
            }

            if ($districtIds->isEmpty()) {
                $districtQuery->whereRaw('1 = 0');
            } else {
                $districtQuery->whereIn('id', $districtIds);
            }
        }

        $districts = $districtQuery->get(['id', 'name', 'province_id'])
            ->map(fn($item) => [
                'id' => $item->id,
                'name' => $item->name,
                'province_id' => $item->province_id,
                'province_name' => $item->province?->name,
            ])
            ->values();

        return inertia('admin/market-insight/Index', [
            'default_fiscal_year' => $defaultFiscalYear,
            'provinces' => Province::query()->orderBy('name')->get(['id', 'name']),
            'districts' => $districts,
            'products' => Product::query()->where('active', true)->orderBy('name')->get(['id', 'name', 'price_1', 'price_2']),
            'bs_users' => User::query()
                ->where('role', User::Role_BS)
                ->orderBy('name')
                ->get(['id', 'name', 'parent_id']),
        ]);
    }

    public function data(Request $request)
    {
        $user = $request->user();

        $fiscalYear = (int) $request->get('fiscal_year', now()->year);
        $month = $request->filled('month') ? (int) $request->get('month') : null;
        $districtId = $request->filled('district_id') ? (int) $request->get('district_id') : null;
        $productId = $request->filled('product_id') ? (int) $request->get('product_id') : null;
        $bsUserId = $request->filled('bs_user_id') ? (int) $request->get('bs_user_id') : null;

        $baseQuery = MarketInsight::query();

        if ($user->role === User::Role_BS) {
            $baseQuery->where('bs_user_id', $user->id);
            $ownedDistrictIds = $user->districts()->pluck('districts.id');
            if ($ownedDistrictIds->isEmpty()) {
                $ownedDistrictIds = $this->getWestJavaDistrictIds();
            }

            if ($ownedDistrictIds->isEmpty()) {
                $baseQuery->whereRaw('1 = 0');
            } else {
                $baseQuery->whereIn('district_id', $ownedDistrictIds);
            }
        }

        if ($user->role === User::Role_Agronomist) {
            $baseQuery->whereHas('bsUser', function ($bsQuery) use ($user) {
                $bsQuery->where('parent_id', $user->id);
            });
        }

        $baseQuery->where('fiscal_year', $fiscalYear);
        if ($month) {
            $baseQuery->where('month', $month);
        }
        if ($productId) {
            $baseQuery->where('product_id', $productId);
        }

        $query = (clone $baseQuery)->with([
            'bsUser:id,name,parent_id',
            'district:id,name,province_id',
            'province:id,name',
            'product:id,name',
        ]);
        if ($districtId) {
            $query->where('district_id', $districtId);
        }
        if ($bsUserId && $user->role !== User::Role_BS) {
            $query->where('bs_user_id', $bsUserId);
        }

        $rows = $query
            ->orderBy('fiscal_year', 'desc')
            ->orderByRaw('COALESCE(month, 0) asc')
            ->orderBy('id', 'desc')
            ->get()
            ->map(function (MarketInsight $item) {
                $actualSalesSeedKg = $this->calculateActualSalesSeedKg(
                    (int) $item->bs_user_id,
                    $item->district_id ? (int) $item->district_id : null,
                    $item->product_id ? (int) $item->product_id : null,
                    (int) $item->fiscal_year,
                    $item->month ? (int) $item->month : null,
                );

                $marketSizeSeedKg = (float) ($item->market_size_seed_kg ?? 0);
                $computedShare = $marketSizeSeedKg > 0
                    ? round(($actualSalesSeedKg / $marketSizeSeedKg) * 100, 2)
                    : null;
                $referencePricePerKg = $marketSizeSeedKg > 0
                    ? round(((float) $item->market_size_value) / $marketSizeSeedKg, 2)
                    : 0;

                return [
                    'id' => $item->id,
                    'bs_user_id' => $item->bs_user_id,
                    'bs_user_name' => $item->bsUser?->name ?? '-',
                    'district_id' => $item->district_id,
                    'district_name' => $item->district?->name ?? '-',
                    'province_id' => $item->province_id,
                    'province_name' => $item->district?->province?->name ?? $item->province?->name ?? '-',
                    'product_id' => $item->product_id,
                    'product_name' => $item->product?->name ?? '-',
                    'fiscal_year' => $item->fiscal_year,
                    'month' => $item->month,
                    'planted_area_ha' => (float) ($item->planted_area_ha ?? 0),
                    'seed_need_per_ha_kg' => (float) ($item->seed_need_per_ha_kg ?? 0),
                    'season_count' => (float) ($item->season_count ?? 0),
                    'market_size_seed_kg' => $marketSizeSeedKg,
                    'reference_price_per_kg' => $referencePricePerKg,
                    'actual_sales_seed_kg' => $actualSalesSeedKg,
                    'market_size_value' => (float) $item->market_size_value,
                    'market_share_percent' => $computedShare,
                    'potential_value' => (float) ($item->potential_value ?? 0),
                    'potential_notes' => $item->potential_notes,
                    'created_datetime' => $item->created_datetime,
                ];
            })
            ->values();

        $totalMarketSizeSeedKg = (float) $rows->sum('market_size_seed_kg');
        $totalActualSalesSeedKg = (float) $rows->sum('actual_sales_seed_kg');
        $avgShare = $totalMarketSizeSeedKg > 0
            ? round(($totalActualSalesSeedKg / $totalMarketSizeSeedKg) * 100, 2)
            : 0;

        $nationalRows = (clone $baseQuery)->get([
            'bs_user_id',
            'district_id',
            'product_id',
            'fiscal_year',
            'month',
            'market_size_seed_kg',
            'market_size_value',
        ]);

        $nationalMarketSizeSeedKg = (float) $nationalRows->sum(fn($row) => (float) ($row->market_size_seed_kg ?? 0));
        $nationalMarketSizeValue = (float) $nationalRows->sum(fn($row) => (float) ($row->market_size_value ?? 0));
        $nationalActualSalesSeedKg = (float) $nationalRows->sum(function ($row) {
            return $this->calculateActualSalesSeedKg(
                (int) $row->bs_user_id,
                $row->district_id ? (int) $row->district_id : null,
                $row->product_id ? (int) $row->product_id : null,
                (int) $row->fiscal_year,
                $row->month ? (int) $row->month : null,
            );
        });
        $nationalShare = $nationalMarketSizeSeedKg > 0
            ? round(($nationalActualSalesSeedKg / $nationalMarketSizeSeedKg) * 100, 2)
            : 0;

        return response()->json([
            'rows' => $rows,
            'summary' => [
                'total_market_size_seed_kg' => $totalMarketSizeSeedKg,
                'total_actual_sales_seed_kg' => $totalActualSalesSeedKg,
                'total_market_size_value' => (float) $rows->sum('market_size_value'),
                'total_potential_value' => (float) $rows->sum('potential_value'),
                'avg_market_share_percent' => (float) $avgShare,
                'total_rows' => (int) $rows->count(),
            ],
            'national_summary' => [
                'total_market_size_seed_kg' => $nationalMarketSizeSeedKg,
                'total_market_size_value' => $nationalMarketSizeValue,
                'total_actual_sales_seed_kg' => $nationalActualSalesSeedKg,
                'avg_market_share_percent' => (float) $nationalShare,
                'total_rows' => (int) $nationalRows->count(),
            ],
        ]);
    }

    public function save(Request $request)
    {
        $user = $request->user();
        if ($user->role !== User::Role_BS) {
            abort(403, 'Hanya BS yang dapat input market size/share.');
        }

        $validated = $request->validate([
            'id' => ['nullable', 'integer', 'exists:market_insights,id'],
            'district_id' => ['required', 'integer', 'exists:districts,id'],
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'fiscal_year' => ['required', 'integer', 'min:2020', 'max:2100'],
            'month' => ['nullable', 'integer', 'min:1', 'max:12'],
            'market_size_seed_kg' => ['required', 'numeric', 'min:0.01'],
            'price_per_kg' => ['nullable', 'numeric', 'min:0.01'],
            'planted_area_ha' => ['nullable', 'numeric', 'min:0'],
            'seed_need_per_ha_kg' => ['nullable', 'numeric', 'min:0'],
            'season_count' => ['nullable', 'numeric', 'min:0'],
            'potential_value' => ['nullable', 'numeric', 'min:0'],
            'potential_notes' => ['nullable', 'string'],
        ]);

        $allowedDistrictIds = $user->districts()->pluck('districts.id');
        if ($allowedDistrictIds->isEmpty()) {
            $allowedDistrictIds = $this->getWestJavaDistrictIds();
        }

        if (!$allowedDistrictIds->contains((int) $validated['district_id'])) {
            abort(422, 'Kabupaten tidak termasuk wilayah BS ini. Silakan atur di Master Data User.');
        }

        $district = District::query()->findOrFail($validated['district_id']);

        $request->validate([
            'fiscal_year' => [
                Rule::unique('market_insights')
                    ->ignore($validated['id'] ?? null)
                    ->where(fn($query) => $query
                        ->where('bs_user_id', $user->id)
                        ->where('district_id', $validated['district_id'])
                        ->where('product_id', $validated['product_id'])
                        ->where('month', $validated['month'] ?? null)),
            ],
        ], [
            'fiscal_year.unique' => 'Data market untuk BS, kabupaten, produk, tahun fiskal, dan bulan tersebut sudah ada.',
        ]);

        $product = Product::query()->findOrFail($validated['product_id']);
        $referencePrice = isset($validated['price_per_kg'])
            ? (float) $validated['price_per_kg']
            : (float) ($product->price_1 ?: $product->price_2 ?: 0);
        $marketSizeSeedKg = round((float) $validated['market_size_seed_kg'], 2);
        $marketSizeValue = round($marketSizeSeedKg * $referencePrice, 2);
        $actualSalesSeedKg = $this->calculateActualSalesSeedKg(
            (int) $user->id,
            (int) $validated['district_id'],
            (int) $validated['product_id'],
            (int) $validated['fiscal_year'],
            isset($validated['month']) ? (int) $validated['month'] : null,
        );
        $computedSharePercent = $marketSizeSeedKg > 0
            ? round(($actualSalesSeedKg / $marketSizeSeedKg) * 100, 2)
            : 0;

        if (!empty($validated['id'])) {
            $item = MarketInsight::query()
                ->where('id', $validated['id'])
                ->where('bs_user_id', $user->id)
                ->firstOrFail();
        } else {
            $item = new MarketInsight();
            $item->bs_user_id = $user->id;
        }

        $item->province_id = $district->province_id;
        $item->district_id = $validated['district_id'];
        $item->product_id = $validated['product_id'];
        $item->fiscal_year = $validated['fiscal_year'];
        $item->month = $validated['month'] ?? null;
        $item->planted_area_ha = isset($validated['planted_area_ha']) ? round((float) $validated['planted_area_ha'], 2) : null;
        $item->seed_need_per_ha_kg = isset($validated['seed_need_per_ha_kg']) ? round((float) $validated['seed_need_per_ha_kg'], 2) : null;
        $item->season_count = isset($validated['season_count']) ? round((float) $validated['season_count'], 2) : null;
        $item->market_size_seed_kg = $marketSizeSeedKg;
        $item->market_size_value = $marketSizeValue;
        $item->market_share_percent = $computedSharePercent;
        $item->potential_value = isset($validated['potential_value'])
            ? round((float) $validated['potential_value'], 2)
            : null;
        $item->potential_notes = $validated['potential_notes'] ?? null;
        $item->save();

        return response()->json([
            'message' => empty($validated['id'])
                ? 'Data market berhasil ditambahkan.'
                : 'Data market berhasil diperbarui.',
        ]);
    }

    public function delete(Request $request, $id)
    {
        $user = $request->user();
        if ($user->role !== User::Role_BS) {
            abort(403, 'Hanya BS yang dapat menghapus input market.');
        }

        $item = MarketInsight::query()
            ->where('id', $id)
            ->where('bs_user_id', $user->id)
            ->firstOrFail();

        $item->delete();

        return response()->json([
            'message' => 'Data market berhasil dihapus.',
        ]);
    }

    private function calculateActualSalesSeedKg(
        int $bsUserId,
        ?int $districtId,
        ?int $productId,
        int $fiscalYear,
        ?int $month,
    ): float {
        if (!$productId) {
            return 0;
        }

        $fyStart = Carbon::createFromDate($fiscalYear, 4, 1)->startOfDay();
        $fyEnd = Carbon::createFromDate($fiscalYear + 1, 3, 31)->endOfDay();

        $query = SaleItem::query()
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->whereBetween('sales.date', [$fyStart, $fyEnd])
            ->where('sales.status', Sale::Status_Released)
            ->where('sales.created_by_uid', $bsUserId)
            ->where('sale_items.product_id', $productId)
            ->where('sale_items.quantity', '>', 0);

        if ($districtId) {
            $query->where('sales.district_id', $districtId);
        }

        if ($month) {
            $query->whereMonth('sales.date', $month);
            $calendarYear = in_array($month, [1, 2, 3], true) ? $fiscalYear + 1 : $fiscalYear;
            $query->whereYear('sales.date', $calendarYear);
        }

        return (float) $query->sum('sale_items.quantity');
    }

    private function getWestJavaDistrictIds()
    {
        $westJavaProvinceId = Province::query()
            ->whereRaw('LOWER(name) = ?', ['jawa barat'])
            ->value('id');

        if (!$westJavaProvinceId) {
            return collect();
        }

        return District::query()
            ->where('province_id', $westJavaProvinceId)
            ->pluck('id');
    }
}
