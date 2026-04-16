<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\DistributorStock;
use App\Models\InventoryLog;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class DistributorStockController extends Controller
{
    private function canDeleteStock(User $user): bool
    {
        return in_array($user->role, [User::Role_Admin, User::Role_Agronomist], true);
    }

    private function getLotStockQty(int $distributorId, int $productId, ?string $lotNumber = null, ?string $expiredDate = null): float
    {
        $signedQtySql = "SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END)";

        $q = StockMovement::query()
            ->where('distributor_id', $distributorId)
            ->where('product_id', $productId);

        $lot = trim((string) ($lotNumber ?? ''));
        if ($lot === '') {
            $q->whereNull('lot_number');
        } else {
            $q->where('lot_number', $lot);
        }

        if (!empty($expiredDate)) {
            $q->whereDate('expired_date', Carbon::parse($expiredDate)->toDateString());
        } else {
            $q->whereNull('expired_date');
        }

        return (float) ($q->selectRaw("COALESCE({$signedQtySql}, 0) as qty")->value('qty') ?? 0);
    }

    private function syncDistributorInventoryLog(
        int $distributorId,
        int $productId,
        ?string $lotNumber = null,
        ?string $expiredDate = null,
        ?string $notes = null,
        ?string $reference = null
    ): void {
        $lotPackage = trim((string) ($lotNumber ?? '')) ?: 'NO-LOT';
        $stockQty = max(0, $this->getLotStockQty($distributorId, $productId, $lotNumber, $expiredDate));
        $product = Product::query()->findOrFail($productId);
        $inventoryQty = $this->buildInventoryQuantities($product, $stockQty);

        $payload = [
            'product_id' => $productId,
            'customer_id' => $distributorId,
            'user_id' => Auth::id(),
            'check_date' => now()->toDateString(),
            'area' => Auth::user()->work_area ?? '-',
            'lot_package' => $lotPackage,
            'quantity' => $inventoryQty['quantity'],
            'base_quantity' => $inventoryQty['base_quantity'],
            'notes' => '[DIST_STOCK_SYNC] ' . trim((string) ($reference ?: 'manual')) . (empty($notes) ? '' : (' | ' . trim((string) $notes))),
        ];

        $existing = InventoryLog::query()
            ->where('customer_id', $distributorId)
            ->where('product_id', $productId)
            ->where('lot_package', $lotPackage)
            ->whereDate('check_date', now()->toDateString())
            ->orderByDesc('id')
            ->first();

        if ($existing) {
            $existing->update($payload);
            return;
        }

        InventoryLog::create($payload);
    }

    private function normalizeUnit(?string $unit): string
    {
        return strtolower(trim((string) $unit));
    }

    private function convertToBaseQty(Product $product, float $qty, ?string $unit): float
    {
        $qty = max(0, (float) $qty);
        $unitNorm = $this->normalizeUnit($unit);
        $uom1 = $this->normalizeUnit($product->uom_1);
        $uom2 = $this->normalizeUnit($product->uom_2);

        if ($qty <= 0 || $unitNorm === '' || $uom1 === '' || $unitNorm === $uom1) {
            return $qty;
        }

        if ($uom2 !== '' && $unitNorm === $uom2) {
            $weightGram = (float) ($product->weight ?? 0);
            if ($weightGram > 0) {
                if ($uom1 === 'kg' && $uom2 === 'pcs') {
                    return round(($qty * $weightGram) / 1000, 6);
                }
                if ($uom1 === 'pcs' && $uom2 === 'kg') {
                    return round(($qty * 1000) / $weightGram, 6);
                }
            }
        }

        return $qty;
    }

    private function convertBaseToUnit(Product $product, float $qty, ?string $targetUnit): float
    {
        $qty = max(0, (float) $qty);
        $targetNorm = $this->normalizeUnit($targetUnit);
        $uom1 = $this->normalizeUnit($product->uom_1);
        $uom2 = $this->normalizeUnit($product->uom_2);

        if ($qty <= 0 || $targetNorm === '' || $uom1 === '' || $targetNorm === $uom1) {
            return $qty;
        }

        if ($uom2 !== '' && $targetNorm === $uom2) {
            $weightGram = (float) ($product->weight ?? 0);
            if ($weightGram > 0) {
                if ($uom1 === 'kg' && $uom2 === 'pcs') {
                    return round(($qty * 1000) / $weightGram, 6);
                }
                if ($uom1 === 'pcs' && $uom2 === 'kg') {
                    return round(($qty * $weightGram) / 1000, 6);
                }
            }
        }

        return $qty;
    }

    private function buildInventoryQuantities(Product $product, float $baseQty): array
    {
        $uom1 = $this->normalizeUnit($product->uom_1);
        $uom2 = $this->normalizeUnit($product->uom_2);

        if ($uom1 === 'kg' && $uom2 === 'pcs') {
            return [
                'quantity' => round($baseQty, 6),
                'base_quantity' => (int) round($this->convertBaseToUnit($product, $baseQty, 'pcs')),
            ];
        }

        if ($uom1 === 'pcs' && $uom2 === 'kg') {
            return [
                'quantity' => round($this->convertBaseToUnit($product, $baseQty, 'kg'), 6),
                'base_quantity' => (int) round($baseQty),
            ];
        }

        return [
            'quantity' => round($baseQty, 6),
            'base_quantity' => (int) round($baseQty),
        ];
    }

    public function index()
    {
        return inertia('admin/distributor-stock/Index', [
            'distributors' => Customer::where('type', Customer::Type_Distributor)->orderBy('name')->get(['id', 'name']),
            'products'     => Product::where('active', true)->orderBy('name')->get(['id', 'name', 'uom_1', 'uom_2', 'weight']),
        ]);
    }

    public function data(Request $request)
    {
        $page    = (int) $request->get('page', 1);
        $perPage = (int) $request->get('per_page', 25);
        $filter  = $request->get('filter', []);

        $q = DistributorStock::query()
            ->from('distributor_stocks as ds')
            ->join('customers as distributor', 'distributor.id', '=', 'ds.distributor_id')
            ->join('products as product', 'product.id', '=', 'ds.product_id')
            ->selectRaw(
                "CONCAT(ds.distributor_id, '-', ds.product_id) as id,
                 ds.distributor_id,
                 distributor.name as distributor_name,
                 ds.product_id,
                 product.name as product_name,
                 COALESCE(product.uom_1, product.uom_2, '') as unit,
                 product.uom_1,
                 product.uom_2,
                 product.weight,
                 NULL as lot_number,
                 NULL as expired_date,
                 NULL as release_datetime,
                 ds.stock_quantity as stock_quantity"
            )
            ->where('ds.stock_quantity', '>', 0);

        if (!empty($filter['distributor_id']) && $filter['distributor_id'] !== 'all') {
            $q->where('ds.distributor_id', (int) $filter['distributor_id']);
        }
        if (!empty($filter['product_id']) && $filter['product_id'] !== 'all') {
            $q->where('ds.product_id', (int) $filter['product_id']);
        }

        $total = DB::query()->fromSub($q, 'g')->count();
        $items = DB::query()
            ->fromSub($q, 'g')
            ->orderByDesc('stock_quantity')
            ->orderBy('distributor_name')
            ->orderBy('product_name')
            ->orderBy('lot_number')
            ->skip(($page - 1) * $perPage)
            ->take($perPage)
            ->get();

        $lotMetaByPair = $this->resolveLotMetaForDistributorProducts($items);

        $items = $items->map(function ($row) use ($lotMetaByPair) {
                $pairKey = ((int) $row->distributor_id) . '-' . ((int) $row->product_id);
                $lotMeta = $lotMetaByPair[$pairKey] ?? null;

                $agingDays = null;
                $releaseDatetime = $lotMeta['release_datetime'] ?? $row->release_datetime;
                if (!empty($releaseDatetime)) {
                    $agingDays = abs(now()->startOfDay()->diffInDays(\Carbon\Carbon::parse($releaseDatetime)->startOfDay(), false));
                }

                return [
                    'id' => $row->id,
                    'distributor_id' => (int) $row->distributor_id,
                    'product_id' => (int) $row->product_id,
                    'distributor' => ['name' => $row->distributor_name],
                    'product' => [
                        'name' => $row->product_name,
                        'unit' => $row->unit,
                        'uom_1' => $row->uom_1,
                        'uom_2' => $row->uom_2,
                        'weight' => (float) ($row->weight ?? 0),
                    ],
                    'lot_number' => $lotMeta['lot_number'] ?? null,
                    'lot_display' => $lotMeta['lot_display'] ?? null,
                    'expired_date' => $lotMeta['expired_date'] ?? $row->expired_date,
                    'release_datetime' => $releaseDatetime,
                    'aging_days' => $agingDays,
                    'stock_quantity' => (float) $row->stock_quantity,
                ];
            })
            ->values();

        return response()->json([
            'data'         => $items,
            'total'        => $total,
            'current_page' => $page,
            'per_page'     => $perPage,
        ]);
    }

    private function resolveLotMetaForDistributorProducts($rows): array
    {
        $pairs = collect($rows)
            ->map(fn($row) => [
                'distributor_id' => (int) ($row->distributor_id ?? 0),
                'product_id' => (int) ($row->product_id ?? 0),
            ])
            ->filter(fn($pair) => $pair['distributor_id'] > 0 && $pair['product_id'] > 0)
            ->values();

        if ($pairs->isEmpty()) {
            return [];
        }

        $pairKeys = $pairs
            ->map(fn($pair) => $pair['distributor_id'] . '-' . $pair['product_id'])
            ->unique()
            ->flip();

        $distributorIds = $pairs->pluck('distributor_id')->unique()->values()->all();
        $productIds = $pairs->pluck('product_id')->unique()->values()->all();

        $signedQtySql = "SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END)";

        $lotRows = StockMovement::query()
            ->whereIn('distributor_id', $distributorIds)
            ->whereIn('product_id', $productIds)
            ->selectRaw(
                "distributor_id,
                 product_id,
                 lot_number,
                 expired_date,
                 MIN(CASE WHEN type = 'in' THEN created_datetime END) as release_datetime,
                 {$signedQtySql} as stock_qty"
            )
            ->groupBy('distributor_id', 'product_id', 'lot_number', 'expired_date')
            ->havingRaw("{$signedQtySql} > 0")
            ->orderByDesc('stock_qty')
            ->get()
            ->filter(function ($row) use ($pairKeys) {
                $pairKey = ((int) $row->distributor_id) . '-' . ((int) $row->product_id);
                return isset($pairKeys[$pairKey]);
            });

        return $lotRows
            ->groupBy(fn($row) => ((int) $row->distributor_id) . '-' . ((int) $row->product_id))
            ->map(function ($group) {
                $primary = $group->first();
                $lotRaw = trim((string) ($primary->lot_number ?? ''));
                $isNoLot = ($lotRaw === '' || strtoupper($lotRaw) === 'NO-LOT');
                $expiredDate = !empty($primary->expired_date)
                    ? Carbon::parse($primary->expired_date)->toDateString()
                    : null;

                return [
                    // Keep raw lot nullable for edit/delete payload compatibility.
                    'lot_number' => $isNoLot ? null : $lotRaw,
                    'lot_display' => $isNoLot ? 'NO-LOT' : $lotRaw,
                    'expired_date' => $expiredDate,
                    'release_datetime' => $primary->release_datetime,
                ];
            })
            ->toArray();
    }

    public function add()
    {
        return inertia('admin/distributor-stock/AddStock', [
            'distributors' => Customer::where('type', Customer::Type_Distributor)->orderBy('name')->get(['id', 'name']),
            'products'     => Product::where('active', true)->orderBy('name')->get(['id', 'name', 'uom_1', 'uom_2', 'weight']),
        ]);
    }

    private function refreshDistributorStockSummary(int $distributorId, int $productId): void
    {
        $signedQtySql = "SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END)";

        $stockQty = (float) (StockMovement::query()
            ->where('distributor_id', $distributorId)
            ->where('product_id', $productId)
            ->selectRaw("COALESCE({$signedQtySql}, 0) as qty")
            ->value('qty') ?? 0);

        $stock = DistributorStock::firstOrNew([
            'distributor_id' => $distributorId,
            'product_id' => $productId,
        ]);

        $stock->stock_quantity = max(0, $stockQty);
        $stock->save();
    }

    public function save(Request $request)
    {
        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id'     => 'required|integer|exists:products,id',
            'notes'          => 'nullable|string|max:500',
            'lots'           => 'required|array|min:1',
            'lots.*.lot_number' => 'nullable|string|max:100',
            'lots.*.expired_date' => 'nullable|date',
            'lots.*.quantity'   => 'required|numeric|min:0.01',
            'lots.*.unit'   => 'required|string|max:20',
        ]);

        DB::transaction(function () use ($request) {
            $product = Product::query()->findOrFail((int) $request->product_id);
            $totalQty = 0.0;

            $stock = DistributorStock::firstOrNew([
                'distributor_id' => $request->distributor_id,
                'product_id'     => $request->product_id,
            ]);

            foreach ($request->lots as $lot) {
                $qtyInput = (float) ($lot['quantity'] ?? 0);
                $qtyBase = $this->convertToBaseQty($product, $qtyInput, $lot['unit'] ?? $product->uom_1);
                $totalQty += $qtyBase;

                StockMovement::create([
                    'distributor_id' => $request->distributor_id,
                    'product_id'     => $request->product_id,
                    'type'           => StockMovement::Type_In,
                    'quantity'       => $qtyBase,
                    'reference'      => 'manual-add-stock',
                    'lot_number'     => $lot['lot_number'] ?? null,
                    'expired_date'   => $lot['expired_date'] ?? null,
                    'notes'          => $request->notes,
                ]);

                $this->syncDistributorInventoryLog(
                    (int) $request->distributor_id,
                    (int) $request->product_id,
                    $lot['lot_number'] ?? null,
                    $lot['expired_date'] ?? null,
                    $request->notes,
                    'manual-add-stock'
                );
            }

            $stock->stock_quantity = ($stock->stock_quantity ?? 0) + $totalQty;
            $stock->save();
        });

        return redirect()->route('admin.distributor-stock.index')
            ->with('success', 'Stok berhasil ditambahkan.');
    }

    public function adjust(Request $request)
    {
        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id'     => 'required|integer|exists:products,id',
            'type'           => 'nullable|in:in,out',
            'quantity'       => 'nullable|numeric|min:0.01',
            'remaining_stock' => 'nullable|numeric|min:0',
            'remaining_stock_unit' => 'nullable|string|max:20',
            'lot_number'     => 'nullable|string|max:100',
            'expired_date'   => 'nullable|date',
            'reference'      => 'nullable|string|max:100',
            'notes'          => 'nullable|string|max:500',
        ]);

        DB::transaction(function () use ($request) {
            $product = Product::query()->findOrFail($request->product_id);
            $lotNumber = $request->filled('lot_number') ? trim((string) $request->lot_number) : null;
            $expiredDate = $request->filled('expired_date')
                ? Carbon::parse((string) $request->expired_date)->toDateString()
                : null;

            $stock = DistributorStock::where('distributor_id', $request->distributor_id)
                ->where('product_id', $request->product_id)
                ->lockForUpdate()
                ->first();

            if (!$stock) {
                $stock = new DistributorStock([
                    'distributor_id' => $request->distributor_id,
                    'product_id' => $request->product_id,
                    'stock_quantity' => 0,
                ]);
            }

            $hasLotScope = ($lotNumber !== null && $lotNumber !== '') || $expiredDate !== null;
            $currentQty = $hasLotScope
                ? $this->getLotStockQty((int) $request->distributor_id, (int) $request->product_id, $lotNumber, $expiredDate)
                : (float) ($stock->stock_quantity ?? 0);

            $movementType = $request->type;
            $qty = (float) ($request->quantity ?? 0);

            // Mode sederhana: user isi stok tersisa, sistem hitung delta otomatis.
            if ($request->filled('remaining_stock')) {
                $remainingInput = (float) $request->remaining_stock;
                $remainingUnit = $request->remaining_stock_unit ?: $product->uom_1;
                $remaining = $this->convertToBaseQty($product, $remainingInput, $remainingUnit);

                if (abs($remaining - $currentQty) < 0.000001) {
                    throw ValidationException::withMessages([
                        'remaining_stock' => 'Stok tersisa sama dengan stok saat ini, tidak ada perubahan.',
                    ]);
                }

                if ($remaining > $currentQty) {
                    $movementType = StockMovement::Type_In;
                    $qty = $remaining - $currentQty;
                } else {
                    $movementType = StockMovement::Type_Out;
                    $qty = $currentQty - $remaining;
                }
            }

            if (!$movementType || $qty <= 0) {
                throw ValidationException::withMessages([
                    'quantity' => 'Isi stok tersisa atau qty penyesuaian yang valid.',
                ]);
            }

            if ($movementType === StockMovement::Type_Out && $qty > $currentQty) {
                throw ValidationException::withMessages([
                    'quantity' => 'Stok tidak cukup untuk pengurangan. Sisa stok saat ini: ' . $currentQty,
                ]);
            }

            $newQty = $movementType === StockMovement::Type_In
                ? $currentQty + $qty
                : $currentQty - $qty;

            $stock->stock_quantity = max(0, $newQty);
            $stock->save();

            StockMovement::create([
                'distributor_id' => $request->distributor_id,
                'product_id'     => $request->product_id,
                'type'           => $movementType,
                'quantity'       => $qty,
                'reference'      => $request->reference ?: 'manual-adjustment',
                'lot_number'     => $lotNumber,
                'expired_date'   => $expiredDate,
                'notes'          => $request->notes,
            ]);

            $this->refreshDistributorStockSummary((int) $request->distributor_id, (int) $request->product_id);

            $this->syncDistributorInventoryLog(
                (int) $request->distributor_id,
                (int) $request->product_id,
                $lotNumber,
                $expiredDate,
                $request->notes,
                $request->reference ?: 'manual-adjustment'
            );
        });

        return response()->json(['message' => 'Penyesuaian stok berhasil disimpan.']);
    }

    public function updateMeta(Request $request)
    {
        $currentUser = Auth::user();
        if (!$this->canDeleteStock($currentUser)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat mengubah metadata stok distributor.');
        }

        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id' => 'required|integer|exists:products,id',
            'old_lot_number' => 'nullable|string|max:100',
            'old_expired_date' => 'nullable|date',
            'lot_number' => 'nullable|string|max:100',
            'expired_date' => 'nullable|date',
        ]);

        DB::transaction(function () use ($request) {
            $oldLot = $request->filled('old_lot_number') ? trim((string) $request->old_lot_number) : null;
            $newLot = $request->filled('lot_number') ? trim((string) $request->lot_number) : null;
            $oldExpired = $request->filled('old_expired_date')
                ? Carbon::parse((string) $request->old_expired_date)->toDateString()
                : null;
            $newExpired = $request->filled('expired_date')
                ? Carbon::parse((string) $request->expired_date)->toDateString()
                : null;

            $movementQuery = StockMovement::query()
                ->where('distributor_id', (int) $request->distributor_id)
                ->where('product_id', (int) $request->product_id);

            if ($oldLot === null || $oldLot === '') {
                $movementQuery->whereNull('lot_number');
            } else {
                $movementQuery->where('lot_number', $oldLot);
            }

            if ($oldExpired !== null) {
                $movementQuery->whereDate('expired_date', $oldExpired);
            } else {
                $movementQuery->whereNull('expired_date');
            }

            $movementCount = $movementQuery->count();
            if ($movementCount <= 0) {
                throw ValidationException::withMessages([
                    'lot_number' => 'Data stok dengan lot/expired lama tidak ditemukan.',
                ]);
            }

            $movementQuery->update([
                'lot_number' => $newLot,
                'expired_date' => $newExpired,
            ]);

            $inventoryQuery = InventoryLog::query()
                ->where('customer_id', (int) $request->distributor_id)
                ->where('product_id', (int) $request->product_id);

            $oldLotPackage = $oldLot ?: 'NO-LOT';
            $newLotPackage = $newLot ?: 'NO-LOT';

            $inventoryQuery->where('lot_package', $oldLotPackage)->update([
                'lot_package' => $newLotPackage,
            ]);
        });

        return response()->json(['message' => 'Metadata lot distributor berhasil diperbarui.']);
    }

    public function movements($distributorId)
    {
        $distributor = Customer::where('type', Customer::Type_Distributor)->findOrFail($distributorId);

        return inertia('admin/distributor-stock/Movements', [
            'distributor' => $distributor,
            'products'    => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function movementsData(Request $request, $distributorId)
    {
        $page    = (int) $request->get('page', 1);
        $perPage = (int) $request->get('per_page', 25);

        $q = StockMovement::with(['product:id,name', 'created_by_user:id,name'])
            ->where('distributor_id', $distributorId);

        if ($request->filled('product_id')) {
            $q->where('product_id', $request->product_id);
        }
        if ($request->filled('type')) {
            $q->where('type', $request->type);
        }

        $total = $q->count();
        $items = $q->orderByDesc('id')->skip(($page - 1) * $perPage)->take($perPage)->get();

        return response()->json([
            'data'         => $items,
            'total'        => $total,
            'current_page' => $page,
            'per_page'     => $perPage,
        ]);
    }

    public function delete(Request $request)
    {
        $currentUser = Auth::user();
        if (!$this->canDeleteStock($currentUser)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat menghapus stok distributor.');
        }

        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id' => 'required|integer|exists:products,id',
            'lot_number' => 'nullable|string|max:100',
            'expired_date' => 'nullable|date',
            'notes' => 'nullable|string|max:500',
        ]);

        DB::transaction(function () use ($request) {
            $stock = DistributorStock::where('distributor_id', $request->distributor_id)
                ->where('product_id', $request->product_id)
                ->lockForUpdate()
                ->first();

            if (!$stock) {
                throw ValidationException::withMessages([
                    'distributor_id' => 'Data stok distributor tidak ditemukan.',
                ]);
            }

            $lotQty = $this->getLotStockQty(
                (int) $request->distributor_id,
                (int) $request->product_id,
                $request->lot_number,
                $request->expired_date
            );

            if ($lotQty <= 0) {
                throw ValidationException::withMessages([
                    'lot_number' => 'Stok lot yang dipilih sudah habis atau tidak ditemukan.',
                ]);
            }

            $currentQty = (float) ($stock->stock_quantity ?? 0);
            $outQty = min($lotQty, $currentQty);

            if ($outQty <= 0) {
                throw ValidationException::withMessages([
                    'product_id' => 'Stok tidak cukup untuk dihapus.',
                ]);
            }

            StockMovement::create([
                'distributor_id' => $request->distributor_id,
                'product_id' => $request->product_id,
                'type' => StockMovement::Type_Out,
                'quantity' => $outQty,
                'reference' => 'manual-delete-stock',
                'lot_number' => $request->lot_number,
                'expired_date' => $request->expired_date,
                'notes' => $request->notes,
            ]);

            $stock->stock_quantity = max(0, $currentQty - $outQty);
            $stock->save();

            $this->syncDistributorInventoryLog(
                (int) $request->distributor_id,
                (int) $request->product_id,
                $request->lot_number,
                $request->expired_date,
                $request->notes,
                'manual-delete-stock'
            );
        });

        return response()->json(['message' => 'Stok distributor berhasil dihapus.']);
    }

}
