<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\DistributorStock;
use App\Models\InventoryLog;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\StockMovement;
use App\Models\User;
use App\Services\FonteWhatsAppService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class SaleController extends Controller
{
    // ─────────────────────────────────────────────────────────────
    //  Helpers
    // ─────────────────────────────────────────────────────────────

    private function isBsRole(?string $role = null): bool
    {
        $normalized = strtolower((string) ($role ?? Auth::user()->role ?? ''));
        return in_array($normalized, [strtolower(User::Role_BS), 'field_officer'], true);
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
                // Contoh umum: base kg, input pcs => kg = pcs * gram/1000
                if ($uom1 === 'kg' && $uom2 === 'pcs') {
                    return round(($qty * $weightGram) / 1000, 6);
                }

                // Kebalikan: base pcs, input kg => pcs = kg * 1000/gram
                if ($uom1 === 'pcs' && $uom2 === 'kg') {
                    return round(($qty * 1000) / $weightGram, 6);
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
            $weightGram = (float) ($product->weight ?? 0);
            return [
                'quantity' => round($baseQty, 6),
                'base_quantity' => $weightGram > 0
                    ? (int) round(($baseQty * 1000) / $weightGram)
                    : (int) round($baseQty),
            ];
        }

        if ($uom1 === 'pcs' && $uom2 === 'kg') {
            $weightGram = (float) ($product->weight ?? 0);
            return [
                'quantity' => $weightGram > 0
                    ? round(($baseQty * $weightGram) / 1000, 6)
                    : round($baseQty, 6),
                'base_quantity' => (int) round($baseQty),
            ];
        }

        return [
            'quantity' => round($baseQty, 6),
            'base_quantity' => (int) round($baseQty),
        ];
    }

    private function roleDefaultSaleType(): string
    {
        $role = Auth::user()->role;
        if ($role === User::Role_Agronomist || $role === User::Role_Admin) {
            return Sale::Type_Distributor;
        }
        return Sale::Type_Retailer;
    }

    private function applyRoleScope($query)
    {
        $role = Auth::user()->role;
        if ($this->isBsRole($role)) {
            $bsId = Auth::id();
            $query->where('sale_type', Sale::Type_Retailer)
                ->where(function ($scopeQuery) use ($bsId) {
                    // BS hanya boleh melihat data yang ia input sendiri
                    // atau retailer yang memang dibuat/di-assign ke BS tersebut.
                    $scopeQuery->where('sales.created_by_uid', $bsId)
                        ->orWhereHas('retailer', function ($retailerQuery) use ($bsId) {
                            $retailerQuery->where(function ($retailerScope) use ($bsId) {
                                $retailerScope->where('created_by_uid', $bsId)
                                    ->orWhere('assigned_user_id', $bsId);
                            });
                        });
                });
        } elseif ($role === User::Role_Agronomist) {
            $agronomistId = Auth::id();
            $query->where(function ($q) use ($agronomistId) {
                // Agronomist dapat melihat:
                // 1. Penjualan distributor (semua)
                // 2. Penjualan retailer yang dibuat oleh BS/FO yang berada di bawah agronomist ini
                // 3. Data import target yang valid
                $q->where('sale_type', Sale::Type_Distributor)
                    ->orWhereIn('sales.created_by_uid', function ($sub) use ($agronomistId) {
                        $sub->select('id')
                            ->from('users')
                            ->whereIn('role', [User::Role_BS, 'field_officer'])
                            ->where('parent_id', $agronomistId);
                    })
                    ->orWhere(function ($importQuery) {
                        $importQuery->where('sales.notes', 'like', '[TARGET_IMPORT]%')
                            ->whereHas('items', fn($itemQuery) => $itemQuery->where('quantity', '>', 0));
                    });
            });
        }
        return $query;
    }

    // ─────────────────────────────────────────────────────────────
    //  Pages
    // ─────────────────────────────────────────────────────────────

    public function index(Request $request)
    {
        $role = Auth::user()->role;

        $retailerQuery = Customer::whereIn('type', [Customer::Type_R1, Customer::Type_R2]);
        if ($this->isBsRole($role)) {
            $retailerQuery->where(function ($q) {
                $q->where('created_by_uid', Auth::id())
                  ->orWhere('assigned_user_id', Auth::id());
            });
        }

        $isBsInbox = in_array($role, [User::Role_Admin, User::Role_Agronomist], true)
            && $request->get('mode') === 'bs-inbox';

        $bsUsers = collect();
        if ($role === User::Role_Admin || $role === User::Role_Agronomist) {
            $bsUsersQuery = User::query()
                ->whereIn('role', [User::Role_BS, 'field_officer'])
                ->select(['id', 'name', 'username'])
                ->orderBy('name');

            if ($role === User::Role_Agronomist) {
                $bsUsersQuery->where('parent_id', Auth::id());
            }

            $bsUsers = $bsUsersQuery->get();
        }

        return inertia('admin/sale/Index', [
            'distributors' => Customer::where('type', Customer::Type_Distributor)
                ->orderBy('name')->get(['id', 'name']),
            'retailers' => $retailerQuery
                ->orderBy('name')->get(['id', 'name', 'type', 'created_by_uid', 'assigned_user_id']),
            'bs_users' => $bsUsers,
            'bs_inbox' => $isBsInbox,
        ]);
    }

    public function add()
    {
        $retailerQuery = Customer::whereIn('type', [Customer::Type_R1, Customer::Type_R2]);
        if ($this->isBsRole()) {
            $retailerQuery->where(function ($q) {
                $q->where('created_by_uid', Auth::id())
                  ->orWhere('assigned_user_id', Auth::id());
            });
        }

        return inertia('admin/sale/Editor', [
            'data'                 => null,
            'products'             => Product::where('active', true)->orderBy('name')
                ->get(['id', 'name', 'uom_1', 'uom_2', 'price_1', 'price_2', 'weight']),
            'distributors'         => Customer::where('type', Customer::Type_Distributor)
                ->orderBy('name')->get(['id', 'name']),
            'retailers'            => $retailerQuery
                ->orderBy('name')->get(['id', 'name', 'type', 'created_by_uid', 'assigned_user_id']),
            'saleType'             => $this->roleDefaultSaleType(),
            'defaultDistributorId' => null,
        ]);
    }

    public function edit($id)
    {
        $sale = Sale::with(['items.product:id,name,uom_1,uom_2,price_1,price_2'])->findOrFail($id);

        $retailerQuery = Customer::whereIn('type', [Customer::Type_R1, Customer::Type_R2]);
        if ($this->isBsRole()) {
            $retailerQuery->where(function ($q) {
                $q->where('created_by_uid', Auth::id())
                  ->orWhere('assigned_user_id', Auth::id());
            });
        }

        return inertia('admin/sale/Editor', [
            'data'                 => $sale,
            'products'             => Product::where('active', true)->orderBy('name')
                ->get(['id', 'name', 'uom_1', 'uom_2', 'price_1', 'price_2', 'weight']),
            'distributors'         => Customer::where('type', Customer::Type_Distributor)
                ->orderBy('name')->get(['id', 'name']),
            'retailers'            => $retailerQuery
                ->orderBy('name')->get(['id', 'name', 'type', 'created_by_uid', 'assigned_user_id']),
            'saleType'             => $sale->sale_type,
            'defaultDistributorId' => null,
        ]);
    }

    public function detail($id)
    {
        $sale = Sale::with([
            'distributor:id,name',
            'retailer:id,name',
            'province:id,name',
            'district:id,name',
            'village:id,name',
            'created_by_user:id,name',
            'updated_by_user:id,name',
            'released_by_user:id,name',
            'items.product:id,name,price_1,price_2',
        ])->findOrFail($id);

        $computedTotal = 0.0;
        $sale->items->transform(function ($item) use (&$computedTotal) {
            $qty = (float) ($item->quantity ?? 0);
            $price = (float) ($item->price ?? 0);
            if ($price <= 0) {
                $price = (float) (($item->product->price_1 ?? 0) ?: ($item->product->price_2 ?? 0));
            }

            $subtotal = round($qty * $price, 2);
            $item->price = $price;
            $item->subtotal = $subtotal;
            $computedTotal += $subtotal;

            return $item;
        });

        $computedTotal = round($computedTotal, 2);
        if ($computedTotal > 0 || (float) ($sale->total_amount ?? 0) <= 0) {
            $sale->total_amount = $computedTotal;
        }

        return inertia('admin/sale/Detail', ['data' => $sale]);
    }

    // ─────────────────────────────────────────────────────────────
    //  JSON API
    // ─────────────────────────────────────────────────────────────

    public function data(Request $request)
    {
        $orderBy   = in_array($request->get('order_by'), ['date', 'total_amount', 'id']) ? $request->get('order_by') : 'date';
        $orderType = $request->get('order_type', 'desc') === 'asc' ? 'asc' : 'desc';
        $page      = (int) $request->get('page', 1);
        $perPage   = (int) $request->get('per_page', 25);
        $filter    = $request->get('filter', []);
        $role      = Auth::user()->role;
        $isBs      = $this->isBsRole($role);

        $q = Sale::with(['distributor:id,name', 'retailer:id,name', 'created_by_user:id,name']);
        $this->applyRoleScope($q);
        $this->applySalesFilters($q, $filter);

        $amountExpr = 'sale_items.quantity * COALESCE(NULLIF(sale_items.price, 0), products.price_1, products.price_2, 0)';

        // Exclude sales where computed total = 0 (e.g. old imported data with qty=0)
        // NOTE: We only exclude if quantity is 0, not if price is 0, to ensure BS sales are counted
        $q->whereExists(function ($sub) {
            $sub->selectRaw('1')
                ->from('sale_items as si')
                ->whereColumn('si.sale_id', 'sales.id')
                ->where('si.quantity', '>', 0);
        });

        // Base total dari query aktif (FY/filter/role scope tetap terpakai)
        $salesSumQuery = (clone $q)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
            ->leftJoin('products', 'products.id', '=', 'sale_items.product_id');
        $totalSalesSum = (float) ($salesSumQuery
            ->selectRaw("COALESCE(SUM({$amountExpr}), 0) as total_amount")
            ->value('total_amount'));

        $qtyQuery = (clone $q)
            ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id');
        $totalQtySum = (float) ($qtyQuery
            ->selectRaw('COALESCE(SUM(sale_items.quantity), 0) as total_qty')
            ->value('total_qty'));

        // Agronomist/Admin: total card harus exclude transaksi yang benar-benar dibuat BS/FO.
        // Jangan kurangi seluruh sale_type=retailer karena data historis impor juga bisa bertipe retailer.
        // BS users (isBs = true) will see their own totals including ALL their sales (pending + released).
        if (!$isBs) {
            $bsAmount = (float) ((clone $q)
                ->whereIn('sales.created_by_uid', function ($sub) {
                    $sub->select('id')
                        ->from('users')
                        ->whereIn('role', [User::Role_BS, 'field_officer']);
                })
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
                ->selectRaw("COALESCE(SUM({$amountExpr}), 0) as total_amount")
                ->value('total_amount'));

            $bsQty = (float) ((clone $q)
                ->whereIn('sales.created_by_uid', function ($sub) {
                    $sub->select('id')
                        ->from('users')
                        ->whereIn('role', [User::Role_BS, 'field_officer']);
                })
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->selectRaw('COALESCE(SUM(sale_items.quantity), 0) as total_qty')
                ->value('total_qty'));

            $totalSalesSum = max(0, $totalSalesSum - $bsAmount);
            $totalQtySum = max(0, $totalQtySum - $bsQty);
        }

        $byDistributor = collect();
        $byRetailer    = collect();

        if ($isBs) {
            // BS: ringkasan per retailer (R1/R2) – hanya released & source_from = distributor
            $groupedRetailer = (clone $q)
                ->where('sales.status', Sale::Status_Released)
                ->where(function ($sq) {
                    $sq->where('sales.source_from', Sale::Source_Distributor)
                       ->orWhereNull('sales.source_from');
                })
                ->join('customers as retailer_cust', 'sales.retailer_id', '=', 'retailer_cust.id')
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
                ->selectRaw("sales.retailer_id, retailer_cust.name as retailer_name, retailer_cust.type as retailer_type, COALESCE(SUM({$amountExpr}), 0) as total_amount, COALESCE(SUM(sale_items.quantity), 0) as total_qty, COUNT(DISTINCT sales.id) as total_rows")
                ->groupBy('sales.retailer_id', 'retailer_cust.name', 'retailer_cust.type')
                ->havingRaw("COALESCE(SUM({$amountExpr}), 0) > 0")
                ->orderByRaw("COALESCE(SUM({$amountExpr}), 0) DESC")
                ->get();

            $byRetailer = $groupedRetailer->map(function ($row) {
                return [
                    'retailer_id'   => (int) $row->retailer_id,
                    'retailer_name' => $row->retailer_name,
                    'retailer_type' => $row->retailer_type,
                    'total_amount'  => (float) $row->total_amount,
                    'total_qty'     => (float) $row->total_qty,
                    'total_rows'    => (int) $row->total_rows,
                ];
            })->values();
        } else {
            // Agronomist/Admin: ringkasan per distributor HANYA dari penjualan distributor.
            // Penjualan BS (sale_type=retailer) tidak boleh menambah nilai penjualan distributor.
            $grouped = (clone $q)
                ->where('sales.sale_type', Sale::Type_Distributor)
                ->join('customers as distributor', 'sales.distributor_id', '=', 'distributor.id')
                ->join('sale_items', 'sale_items.sale_id', '=', 'sales.id')
                ->leftJoin('products', 'products.id', '=', 'sale_items.product_id')
                ->selectRaw("sales.distributor_id, distributor.name as distributor_name, COALESCE(SUM({$amountExpr}), 0) as total_amount, COALESCE(SUM(sale_items.quantity), 0) as total_qty, COUNT(DISTINCT sales.id) as total_rows")
                ->groupBy('sales.distributor_id', 'distributor.name')
                ->havingRaw("COALESCE(SUM({$amountExpr}), 0) > 0")
                ->orderByRaw("COALESCE(SUM({$amountExpr}), 0) DESC")
                ->get();

            $byDistributor = $grouped->map(function ($row) {
                return [
                    'distributor_id'   => (int) $row->distributor_id,
                    'distributor_name' => $row->distributor_name,
                    'total_amount'     => (float) $row->total_amount,
                    'total_qty'        => (float) $row->total_qty,
                    'total_rows'       => (int) $row->total_rows,
                ];
            })->values();
        }

        $total = $q->count();
        $items = $q->orderBy($orderBy, $orderType)
            ->skip(($page - 1) * $perPage)->take($perPage)->get();

        return response()->json([
            'data'            => $items,
            'total'           => $total,
            'current_page'    => $page,
            'per_page'        => $perPage,
            'total_sales_sum' => $totalSalesSum,
            'total_qty_sum'   => (float) $totalQtySum,
            'by_distributor'  => $byDistributor,
            'by_retailer'     => $byRetailer,
        ]);
    }

    public function distributorStocks(Request $request)
    {
        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
        ]);

        $distributorId = (int) $request->integer('distributor_id');

        $rows = DistributorStock::with('product:id,name,uom_1,uom_2,weight')
            ->where('distributor_id', $distributorId)
            ->orderBy('product_id')
            ->get()
            ->map(function ($row) {
                return [
                    'product_id' => (int) $row->product_id,
                    'product_name' => $row->product?->name,
                    'unit' => $row->product?->uom_1 ?: $row->product?->uom_2,
                    'uom_1' => $row->product?->uom_1,
                    'uom_2' => $row->product?->uom_2,
                    'weight' => (float) ($row->product?->weight ?? 0),
                    'stock_quantity' => (float) ($row->stock_quantity ?? 0),
                ];
            })
            ->values();

        return response()->json([
            'rows' => $rows,
            'total_rows' => (int) $rows->count(),
        ]);
    }

    public function distributorDetail(Request $request)
    {
        $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
        ]);

        $filter = $request->get('filter', []);
        $distributorId = (int) $request->integer('distributor_id');

        $q = Sale::with(['distributor:id,name', 'retailer:id,name', 'items.product:id,name'])
            ->where('distributor_id', $distributorId)
            // Detail distributor hanya menampilkan transaksi distributor.
            ->where('sale_type', Sale::Type_Distributor);

        $this->applyRoleScope($q);
        $this->applySalesFilters($q, $filter);

        $rows = $q->orderByDesc('date')->orderByDesc('id')->limit(300)->get();

        $rows->transform(function ($sale) {
            $computedTotal = (float) $sale->items->sum(function ($item) {
                $price = (float) ($item->price ?? 0);
                if ($price <= 0) {
                    $price = (float) (($item->product->price_1 ?? 0) ?: ($item->product->price_2 ?? 0));
                }
                return (float) ($item->quantity ?? 0) * $price;
            });

            if ($computedTotal > 0 || (float) ($sale->total_amount ?? 0) <= 0) {
                $sale->total_amount = round($computedTotal, 2);
            }

            return $sale;
        });

        return response()->json([
            'rows' => $rows,
            'total_amount' => (float) $rows->sum('total_amount'),
            'total_qty' => (float) $rows->sum(fn($sale) => $sale->items->sum('quantity')),
            'total_rows' => (int) $rows->count(),
        ]);
    }

    private function applySalesFilters($q, array $filter): void
    {
        if (!empty($filter['bs_user_id'])) {
            $bsUserId = (int) $filter['bs_user_id'];
            $q->where('sales.created_by_uid', $bsUserId)
                ->whereHas('retailer', function ($retailerQuery) use ($bsUserId) {
                    $retailerQuery->where(function ($qq) use ($bsUserId) {
                        $qq->where('created_by_uid', $bsUserId)
                           ->orWhere('assigned_user_id', $bsUserId);
                    });
                });
        }

        if (!empty($filter['bs_only'])) {
            $q->whereIn('sales.created_by_uid', function ($sub) {
                $sub->select('id')
                    ->from('users')
                    ->whereIn('role', [User::Role_BS, 'field_officer']);
            });
        }

        if (!empty($filter['search'])) {
            $term = '%' . $filter['search'] . '%';
            $q->where(function ($qq) use ($term) {
                $qq->whereHas('distributor', fn($r) => $r->where('name', 'like', $term))
                    ->orWhereHas('retailer', fn($r) => $r->where('name', 'like', $term));
            });
        }

        if (!empty($filter['distributor_id'])) {
            $q->where('distributor_id', $filter['distributor_id']);
        }

        if (!empty($filter['retailer_id'])) {
            $q->where('retailer_id', $filter['retailer_id']);
        }

        if (!empty($filter['fiscal_year'])) {
            $fy = (int) $filter['fiscal_year'];
            $q->where(function ($qq) use ($fy) {
                $qq->whereBetween('date', ["{$fy}-04-01", "{$fy}-12-31"])
                    ->orWhereBetween('date', [($fy + 1) . "-01-01", ($fy + 1) . "-03-31"]);
            });
        }

        if (!empty($filter['month'])) {
            $q->whereMonth('date', $filter['month']);
        }

        if (!empty($filter['status']) && in_array($filter['status'], [Sale::Status_Pending, Sale::Status_Released])) {
            $q->where('status', $filter['status']);
        }
    }

    // ─────────────────────────────────────────────────────────────
    //  Save (create / update)
    // ─────────────────────────────────────────────────────────────

    public function save(Request $request)
    {
        $request->validate([
            'sale_type'      => 'required|in:retailer,distributor',
            'date'           => 'required|date',
            'distributor_id' => 'required|integer|exists:customers,id',
            'retailer_id'    => 'required_if:sale_type,retailer|nullable|integer|exists:customers,id',
            'source_from'    => 'nullable|in:distributor,r1',
            'notes'          => 'nullable|string|max:1000',
            'items'          => 'required|array|min:1',
            'items.*.product_id' => 'required|integer|exists:products,id',
            'items.*.lot_number' => 'nullable|string|max:100',
            'items.*.expired_date' => 'nullable|date',
            'items.*.quantity'   => 'required|numeric|min:0.01',
            'items.*.unit'       => 'nullable|string|max:20',
            'items.*.price'      => 'required|numeric|min:0.01',
        ]);

        // Tentukan source_from: R1 selalu dari distributor, R2 bisa distributor atau r1
        $sourceFrom = null;
        if ($request->sale_type === Sale::Type_Retailer && !empty($request->retailer_id)) {
            $retailer = Customer::find($request->retailer_id);
            if ($retailer && $retailer->type === Customer::Type_R1) {
                $sourceFrom = Sale::Source_Distributor; // R1 selalu dari distributor
            } else {
                $sourceFrom = $request->source_from === Sale::Source_R1
                    ? Sale::Source_R1
                    : Sale::Source_Distributor;
            }
        }

        $isNew = empty($request->id);
        $savedSale = null;
        $canManageReleased = in_array(Auth::user()->role, [User::Role_Admin, User::Role_Agronomist]);

        DB::transaction(function () use ($request, $isNew, $canManageReleased, $sourceFrom, &$savedSale) {
            $requestedProductIds = collect($request->items ?? [])->pluck('product_id')->filter()->map(fn($id) => (int) $id)->unique()->values();
            $productMap = Product::query()
                ->whereIn('id', $requestedProductIds)
                ->get(['id', 'uom_1', 'uom_2', 'weight'])
                ->keyBy('id');

            $old = null;
            if (!$isNew) {
                $old = Sale::with('items.product:id,uom_1,uom_2,weight')->lockForUpdate()->findOrFail($request->id);
                if ($old->status === Sale::Status_Released) {
                    if (!$canManageReleased) {
                        throw ValidationException::withMessages([
                            'id' => 'Data yang sudah release tidak bisa diedit.',
                        ]);
                    }

                    // Reverse stok lama hanya jika source_from sebelumnya bukan r1
                    foreach ($old->items as $oldItem) {
                        if ($old->source_from !== Sale::Source_R1) {
                            $oldQtyBase = $oldItem->product
                                ? $this->convertToBaseQty($oldItem->product, (float) $oldItem->quantity, $oldItem->unit)
                                : (float) $oldItem->quantity;

                            $this->adjustStock(
                                $old->sale_type,
                                (int) $old->distributor_id,
                                (int) $oldItem->product_id,
                                $oldQtyBase,
                                $oldItem->lot_number,
                                $oldItem->expired_date,
                                (int) ($old->retailer_id ?? 0),
                                (string) $old->date,
                                                                (int) $old->id,
                                                                inventoryUserId: (int) ($old->created_by_uid ?? Auth::id()),
                                reverse: true
                            );
                        }
                    }
                }
            }

            if ($request->sale_type === Sale::Type_Retailer) {
                $requestedByProduct = [];
                foreach ($request->items as $item) {
                    $productId = (int) ($item['product_id'] ?? 0);
                    $qtyInput = (float) ($item['quantity'] ?? 0);
                    $product = $productMap->get($productId);
                    $qtyBase = $product
                        ? $this->convertToBaseQty($product, $qtyInput, $item['unit'] ?? null)
                        : $qtyInput;

                    if ($productId <= 0 || $qtyBase <= 0) {
                        continue;
                    }
                    $requestedByProduct[$productId] = ($requestedByProduct[$productId] ?? 0) + $qtyBase;
                }

                $oldReleasedByProduct = [];
                if (!$isNew && $old && $old->status === Sale::Status_Released) {
                    foreach ($old->items as $oldItem) {
                        $oldQtyBase = $oldItem->product
                            ? $this->convertToBaseQty($oldItem->product, (float) $oldItem->quantity, $oldItem->unit)
                            : (float) $oldItem->quantity;

                        $oldReleasedByProduct[(int) $oldItem->product_id] =
                            ($oldReleasedByProduct[(int) $oldItem->product_id] ?? 0) + $oldQtyBase;
                    }
                }

                // Validasi stok hanya jika barang diambil dari distributor (bukan dari R1)
                $newSourceFrom = $sourceFrom ?? Sale::Source_Distributor;
                $oldSourceFrom = $old?->source_from ?? Sale::Source_Distributor;
                $needsStockCheck = $newSourceFrom !== Sale::Source_R1;

                if ($needsStockCheck) {
                    $stockRows = DistributorStock::where('distributor_id', (int) $request->distributor_id)
                        ->whereIn('product_id', array_keys($requestedByProduct))
                        ->lockForUpdate()
                        ->get()
                        ->keyBy('product_id');

                    $errors = [];
                    foreach ($requestedByProduct as $productId => $requestedQty) {
                        $product = $productMap->get((int) $productId);
                        $baseUnit = $product?->uom_1 ?: 'unit';

                        // Kalau edit dari source_from distributor ke distributor, kembalikan stok lama
                        $restoredFromOld = ($oldSourceFrom !== Sale::Source_R1)
                            ? (float) ($oldReleasedByProduct[$productId] ?? 0)
                            : 0.0;

                        $currentStock = (float) ($stockRows->get($productId)?->stock_quantity ?? 0);
                        $available = $currentStock + $restoredFromOld;

                        if ($available <= 0) {
                            $errors[] = "Produk #{$productId} stok distributor 0 {$baseUnit}.";
                            continue;
                        }

                        if ($requestedQty > $available) {
                            $errors[] = "Produk #{$productId} melebihi stok. Diminta {$requestedQty} {$baseUnit}, tersedia {$available} {$baseUnit}.";
                        }
                    }

                    if (!empty($errors)) {
                        throw ValidationException::withMessages([
                            'items' => implode(' ', $errors),
                        ]);
                    }
                }
            }

            // ── Calculate totals ──
            $totalAmount = 0;
            $itemsData   = [];
            foreach ($request->items as $it) {
                $productId = (int) ($it['product_id'] ?? 0);
                $product = $productMap->get($productId);
                $qtyInput = (float) ($it['quantity'] ?? 0);
                $qtyBase = $product
                    ? $this->convertToBaseQty($product, $qtyInput, $it['unit'] ?? null)
                    : $qtyInput;

                $subtotal     = round((float)$it['quantity'] * (float)$it['price'], 2);
                $totalAmount += $subtotal;
                $itemsData[]  = [
                    'product_id' => $productId,
                    'lot_number' => $it['lot_number'] ?? null,
                    'expired_date' => $it['expired_date'] ?? null,
                    'quantity'   => $qtyInput,
                    'base_quantity' => $qtyBase,
                    'unit'       => $it['unit'] ?? '',
                    'price'      => $it['price'],
                    'subtotal'   => $subtotal,
                ];
            }

            // ── Upsert Sale ──
            $saleData = [
                'sale_type'      => $request->sale_type,
                'status'         => (!$isNew && $old && $old->status === Sale::Status_Released)
                    ? Sale::Status_Released
                    : Sale::Status_Pending,
                'source_from'    => $sourceFrom,
                'date'           => $request->date,
                'distributor_id' => $request->distributor_id,
                'retailer_id'    => $request->retailer_id ?: null,
                'province_id'    => null,
                'district_id'    => null,
                'village_id'     => null,
                'notes'          => $request->notes,
                'total_amount'   => $totalAmount,
                'released_datetime' => (!$isNew && $old && $old->status === Sale::Status_Released)
                    ? ($old->released_datetime ?: now())
                    : null,
                'released_by_uid'   => (!$isNew && $old && $old->status === Sale::Status_Released)
                    ? ($old->released_by_uid ?: Auth::id())
                    : null,
            ];

            if ($isNew) {
                $sale = Sale::create($saleData);
            } else {
                $sale = Sale::findOrFail($request->id);
                $sale->update($saleData);
                $sale->items()->delete();
            }

            // ── Create items ──
            foreach ($itemsData as $it) {
                $it['sale_id'] = $sale->id;
                SaleItem::create($it);

                // Adjust stok hanya jika edit released dan source_from bukan r1
                if (!$isNew && $old && $old->status === Sale::Status_Released && $sale->source_from !== Sale::Source_R1) {
                    $this->adjustStock(
                        $sale->sale_type,
                        (int) $sale->distributor_id,
                        (int) $it['product_id'],
                        (float) $it['base_quantity'],
                        $it['lot_number'] ?? null,
                        $it['expired_date'] ?? null,
                        (int) ($sale->retailer_id ?? 0),
                        (string) $sale->date,
                        (int) $sale->id,
                        inventoryUserId: (int) ($sale->created_by_uid ?? Auth::id()),
                        reverse: false
                    );
                }
            }

            $savedSale = $sale->fresh(['distributor:id,name', 'retailer:id,name']);
        });

        if ($isNew && $this->isBsRole() && $savedSale) {
            $waService = app(FonteWhatsAppService::class);
            $waService->sendSaleInputNotificationToOwner(Auth::user(), $savedSale);
            $waService->sendSaleInputNotificationToBs(Auth::user(), $savedSale);

            $agronomistUser = Auth::user()->parent;
            if ($agronomistUser && $agronomistUser->role === User::Role_Agronomist) {
                $waService->sendSaleInputNotificationToAgronomist($agronomistUser, Auth::user(), $savedSale);
            }
        }

        return redirect()->route('admin.sale.index')
            ->with('success', $isNew ? 'PO penjualan berhasil disimpan (pending release).' : 'PO penjualan berhasil diperbarui.');
    }

    public function releaseData($id)
    {
        $sale = Sale::with(['distributor:id,name', 'items.product:id,name'])->findOrFail($id);

        if ($sale->status === Sale::Status_Released) {
            return response()->json([
                'message' => 'Data sudah release.',
                'data'    => null,
            ], 422);
        }

        return response()->json([
            'data' => [
                'id' => $sale->id,
                'sale_type' => $sale->sale_type,
                'date' => $sale->date,
                'distributor' => $sale->distributor,
                'items' => $sale->items->map(function ($it) {
                    return [
                        'id' => $it->id,
                        'product_id' => $it->product_id,
                        'product_name' => $it->product?->name,
                        'quantity' => (float) $it->quantity,
                        'unit' => $it->unit,
                        'lot_number' => $it->lot_number,
                        'expired_date' => $it->expired_date,
                    ];
                })->values(),
            ],
        ]);
    }

    public function release(Request $request, $id)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.id' => 'required|integer|exists:sale_items,id',
            'items.*.quantity' => 'nullable|numeric|min:0.01',
            'items.*.remaining_stock' => 'nullable|numeric|min:0',
            'items.*.lot_number' => 'nullable|string|max:100',
            'items.*.expired_date' => 'nullable|date',
        ]);

        $releasedSale = null;

        DB::transaction(function () use ($request, $id, &$releasedSale) {
            $sale = Sale::with('items.product:id,uom_1,uom_2,weight')->lockForUpdate()->findOrFail($id);

            if ($sale->status === Sale::Status_Released) {
                throw ValidationException::withMessages([
                    'status' => 'Data sudah release.',
                ]);
            }

            $releaseItemMap = collect($request->items)->keyBy('id');

            $newTotalAmount = 0;

            foreach ($sale->items as $item) {
                $payload = $releaseItemMap->get($item->id, []);
                $lotNumber = $payload['lot_number'] ?? null;
                $expiredDate = $payload['expired_date'] ?? null;

                $existingQty = (float) $item->quantity;
                $releasedQty = isset($payload['quantity']) ? (float) $payload['quantity'] : $existingQty;

                if ($releasedQty <= 0) {
                    throw ValidationException::withMessages([
                        'items' => "Qty release untuk item #{$item->id} harus lebih dari 0.",
                    ]);
                }

                if ($releasedQty > $existingQty) {
                    throw ValidationException::withMessages([
                        'items' => "Qty release item #{$item->id} tidak boleh melebihi qty PO ({$existingQty}).",
                    ]);
                }

                $remainingStockInput = isset($payload['remaining_stock']) && $payload['remaining_stock'] !== ''
                    ? (float) $payload['remaining_stock']
                    : null;

                $newSubtotal = round($releasedQty * (float) ($item->price ?? 0), 2);
                $item->update([
                    'quantity' => $releasedQty,
                    'subtotal' => $newSubtotal,
                    'lot_number' => $lotNumber,
                    'expired_date' => $expiredDate,
                ]);

                $newTotalAmount += $newSubtotal;

                // Hanya adjust stok distributor jika barang dari distributor (bukan dari R1)
                if ($sale->source_from !== Sale::Source_R1) {
                    $qtyBase = $item->product
                        ? $this->convertToBaseQty($item->product, $releasedQty, $item->unit)
                        : $releasedQty;

                    $remainingStockBase = null;
                    if ($remainingStockInput !== null) {
                        $remainingStockBase = $item->product
                            ? $this->convertToBaseQty($item->product, $remainingStockInput, $item->unit)
                            : $remainingStockInput;
                    }

                    $this->adjustStock(
                        $sale->sale_type,
                        (int) $sale->distributor_id,
                        (int) $item->product_id,
                        $qtyBase,
                        $lotNumber,
                        $expiredDate,
                        (int) ($sale->retailer_id ?? 0),
                        (string) $sale->date,
                        (int) $sale->id,
                        $remainingStockBase,
                        inventoryUserId: (int) ($sale->created_by_uid ?? Auth::id()),
                        reverse: false
                    );
                }
            }

            $sale->update([
                'status' => Sale::Status_Released,
                'total_amount' => round($newTotalAmount, 2),
                'released_datetime' => now(),
                'released_by_uid' => Auth::id(),
            ]);

            $releasedSale = $sale->fresh([
                'distributor:id,name',
                'retailer:id,name',
                'created_by_user:id,name,username,whatsapp_number,role',
            ]);
        });

        if ($releasedSale) {
            $waService = app(FonteWhatsAppService::class);
            $waService->sendSaleReleasedNotificationToOwner($releasedSale, Auth::user());

            $bsUser = $releasedSale->created_by_user;
            if ($bsUser && $this->isBsRole($bsUser->role)) {
                $waService->sendSaleReleasedNotificationToBs($bsUser, $releasedSale);
            }
        }

        return response()->json(['message' => 'PO berhasil di-release.']);
    }

    private function adjustStock(string $saleType, int $distributorId, int $productId, float $qty, ?string $lotNumber = null, ?string $expiredDate = null, int $retailerId = 0, ?string $movementDate = null, ?int $saleId = null, ?float $remainingStockBase = null, ?int $inventoryUserId = null, bool $reverse = false): void
    {
        // retailer sale → stock goes OUT from distributor
        // distributor sale → stock comes IN to distributor
        $isIn = ($saleType === Sale::Type_Distributor);
        if ($reverse) $isIn = !$isIn;

        $movType = $isIn ? StockMovement::Type_In : StockMovement::Type_Out;

        StockMovement::create([
            'distributor_id' => $distributorId,
            'product_id'     => $productId,
            'type'           => $movType,
            'quantity'       => $qty,
            'reference'      => 'sale',
            'lot_number'     => $lotNumber,
            'expired_date'   => $expiredDate,
        ]);

        $this->refreshDistributorStockSummary($distributorId, $productId);

        if ($distributorId > 0) {
            $this->syncDistributorInventoryLogForSale(
                $distributorId,
                $productId,
                $lotNumber,
                $movementDate,
                $saleId,
                $inventoryUserId,
                $movType === StockMovement::Type_In
            );
        }

        if ($saleType === Sale::Type_Retailer && $retailerId > 0) {
            $deltaInventory = $reverse ? -$qty : $qty;
            $this->syncRetailerInventoryLog(
                $retailerId,
                $productId,
                $deltaInventory,
                $lotNumber,
                $movementDate,
                $saleId,
                $remainingStockBase,
                $inventoryUserId
            );
        }
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

    private function syncDistributorInventoryLogForSale(
        int $distributorId,
        int $productId,
        ?string $lotNumber,
        ?string $movementDate,
        ?int $saleId,
        ?int $inventoryUserId,
        bool $isIn
    ): void {
        $lotPackage = trim((string) ($lotNumber ?? '')) ?: 'NO-LOT';
        $checkDate = $movementDate ? Carbon::parse($movementDate)->toDateString() : now()->toDateString();
        $signedQtySql = "SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END)";

        $stockQty = (float) (StockMovement::query()
            ->where('distributor_id', $distributorId)
            ->where('product_id', $productId)
            ->when($lotPackage === 'NO-LOT', fn($q) => $q->whereNull('lot_number'), fn($q) => $q->where('lot_number', $lotPackage))
            ->selectRaw("COALESCE({$signedQtySql}, 0) as qty")
            ->value('qty') ?? 0);

        $product = Product::query()->find($productId);
        if (!$product) {
            return;
        }

        $inventoryQty = $this->buildInventoryQuantities($product, max(0, $stockQty));

        $payload = [
            'product_id' => $productId,
            'customer_id' => $distributorId,
            'user_id' => $inventoryUserId ?: Auth::id(),
            'check_date' => $checkDate,
            'area' => Auth::user()->work_area ?? '-',
            'lot_package' => $lotPackage,
            'quantity' => $inventoryQty['quantity'],
            'base_quantity' => $inventoryQty['base_quantity'],
            'reference_sale_id' => $saleId,
            'notes' => '[DIST_STOCK_SYNC' . ($saleId ? ('#' . $saleId) : '') . '] ' . ($isIn ? 'IN' : 'OUT') . ' via sales',
        ];

        $existing = null;
        if ($saleId) {
            $existing = InventoryLog::query()
                ->where('reference_sale_id', $saleId)
                ->where('customer_id', $distributorId)
                ->where('product_id', $productId)
                ->where('lot_package', $lotPackage)
                ->orderByDesc('id')
                ->first();
        }

        if (!$existing) {
            $existing = InventoryLog::query()
                ->where('customer_id', $distributorId)
                ->where('product_id', $productId)
                ->where('lot_package', $lotPackage)
                ->whereDate('check_date', $checkDate)
                ->where('notes', 'like', '[DIST_STOCK_SYNC%')
                ->orderByDesc('id')
                ->first();
        }

        if ($existing) {
            $existing->update($payload);
            return;
        }

        InventoryLog::create($payload);
    }

    private function syncRetailerInventoryLog(int $retailerId, int $productId, float $deltaQty, ?string $lotNumber, ?string $movementDate = null, ?int $saleId = null, ?float $remainingStockBase = null, ?int $inventoryUserId = null): void
    {
        $lotPackage = trim((string) ($lotNumber ?? '')) ?: 'NO-LOT';

        $latest = InventoryLog::where('customer_id', $retailerId)
            ->where('product_id', $productId)
            ->where('lot_package', $lotPackage)
            ->orderByDesc('check_date')
            ->orderByDesc('id')
            ->first();

        $lastQty = (float) ($latest?->quantity ?? 0);
        $newQty = $remainingStockBase !== null
            ? max(0, $remainingStockBase)
            : max(0, $lastQty + $deltaQty);

        $checkDate = $movementDate
            ? Carbon::parse($movementDate)->toDateString()
            : now()->toDateString();

        $payload = [
            'product_id' => $productId,
            'customer_id' => $retailerId,
            'user_id' => $inventoryUserId ?: Auth::id(),
            'check_date' => $checkDate,
            'area' => Auth::user()->work_area ?? '-',
            'lot_package' => $lotPackage,
            'quantity' => $newQty,
            'base_quantity' => 1,
            'reference_sale_id' => $saleId,
            'notes' => '[SALE_SYNC' . ($saleId ? ('#' . $saleId) : '') . '] ' . ($deltaQty >= 0 ? 'IN' : 'OUT') . ' via sales',
        ];

        if ($saleId) {
            $existing = InventoryLog::where('reference_sale_id', $saleId)
                ->where('customer_id', $retailerId)
                ->where('product_id', $productId)
                ->where('lot_package', $lotPackage)
                ->orderByDesc('id')
                ->first();

            if ($existing) {
                $existing->update($payload);
                return;
            }
        }

        InventoryLog::create($payload);
    }

    // ─────────────────────────────────────────────────────────────
    //  Delete
    // ─────────────────────────────────────────────────────────────

    public function delete($id)
    {
        $currentUser = Auth::user();
        $canForceDelete = in_array($currentUser->role, [User::Role_Admin, User::Role_Agronomist]);

        DB::transaction(function () use ($id, $canForceDelete) {
            $sale = Sale::with('items.product:id,uom_1,uom_2,weight')->findOrFail($id);

            if ($sale->status === Sale::Status_Released) {
                if (!$canForceDelete) {
                    throw ValidationException::withMessages([
                        'id' => 'Data yang sudah release tidak bisa dihapus.',
                    ]);
                }
                // Reverse stock for each item (hanya jika source_from = distributor)
                foreach ($sale->items as $item) {
                    if ($sale->source_from !== Sale::Source_R1) {
                        $qtyBase = $item->product
                            ? $this->convertToBaseQty($item->product, (float) $item->quantity, $item->unit)
                            : (float) $item->quantity;

                        $this->adjustStock(
                            $sale->sale_type,
                            (int) $sale->distributor_id,
                            (int) $item->product_id,
                            $qtyBase,
                            $item->lot_number,
                            $item->expired_date,
                            (int) ($sale->retailer_id ?? 0),
                            (string) $sale->date,
                            (int) $sale->id,
                            inventoryUserId: (int) ($sale->created_by_uid ?? Auth::id()),
                            reverse: true
                        );
                    }
                }

                InventoryLog::where('reference_sale_id', (int) $sale->id)->delete();
                InventoryLog::where('notes', 'like', '[SALE_SYNC#' . (int) $sale->id . ']%')->delete();

                if ($sale->sale_type === Sale::Type_Retailer && (int) ($sale->retailer_id ?? 0) > 0) {
                    InventoryLog::whereNull('reference_sale_id')
                        ->where('customer_id', (int) $sale->retailer_id)
                        ->whereIn('product_id', $sale->items->pluck('product_id')->map(fn($id) => (int) $id)->all())
                        ->whereDate('check_date', Carbon::parse($sale->date)->toDateString())
                        ->where('notes', 'like', '[SALE_SYNC%')
                        ->delete();
                }
            }

            $sale->delete(); // cascade deletes items
        });

        return response()->json(['message' => 'Penjualan berhasil dihapus.']);
    }

    // ─────────────────────────────────────────────────────────────
    //  Export / Import (basic stubs — expandable)
    // ─────────────────────────────────────────────────────────────

    public function export(Request $request)
    {
        $filter = $request->get('filter', []);
        $format = $request->get('format', 'excel');

        $q = Sale::with(['distributor:id,name', 'retailer:id,name', 'items.product:id,name']);
        $this->applyRoleScope($q);

        if (!empty($filter['fiscal_year'])) {
            $fy = (int) $filter['fiscal_year'];
            $q->where(function ($qq) use ($fy) {
                $qq->whereBetween('date', ["{$fy}-04-01", "{$fy}-12-31"])
                   ->orWhereBetween('date', [($fy + 1) . "-01-01", ($fy + 1) . "-03-31"]);
            });
        }

        $sales = $q->orderByDesc('date')->get();

        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet       = $spreadsheet->getActiveSheet();

        $headers = ['#', 'Tanggal', 'Tipe', 'Distributor', 'Retailer/Toko', 'Total (Rp)'];
        foreach ($headers as $i => $h) {
            $sheet->setCellValueByColumnAndRow($i + 1, 1, $h);
        }

        foreach ($sales as $idx => $sale) {
            $row = $idx + 2;
            $sheet->setCellValueByColumnAndRow(1, $row, $idx + 1);
            $sheet->setCellValueByColumnAndRow(2, $row, $sale->date?->format('Y-m-d'));
            $sheet->setCellValueByColumnAndRow(3, $row, $sale->sale_type);
            $sheet->setCellValueByColumnAndRow(4, $row, $sale->distributor?->name);
            $sheet->setCellValueByColumnAndRow(5, $row, $sale->retailer?->name);
            $sheet->setCellValueByColumnAndRow(6, $row, $sale->total_amount);
        }

        $filename = 'penjualan_' . now()->format('Ymd_His') . '.xlsx';
        $writer   = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);

        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, $filename, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ]);
    }

    public function importTemplate()
    {
        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet       = $spreadsheet->getActiveSheet();
        $headers     = ['Tanggal (YYYY-MM-DD)', 'Tipe (retailer/distributor)', 'Distributor ID', 'Retailer ID (opsional)', 'Product ID', 'Qty', 'Unit', 'Harga Satuan'];
        foreach ($headers as $i => $h) {
            $sheet->setCellValueByColumnAndRow($i + 1, 1, $h);
        }
        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, 'template_import_penjualan.xlsx', [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ]);
    }

    public function import(Request $request)
    {
        $request->validate(['file' => 'required|file|mimes:xlsx,xls']);

        $reader      = new \PhpOffice\PhpSpreadsheet\Reader\Xlsx();
        $spreadsheet = $reader->load($request->file('file')->getPathname());
        $rows        = $spreadsheet->getActiveSheet()->toArray(null, true, true, true);

        $imported = 0;
        DB::transaction(function () use ($rows, &$imported) {
            foreach (array_slice($rows, 1) as $row) {
                if (empty($row['A'])) continue;

                $saleType = trim($row['B'] ?? '');
                if (!in_array($saleType, ['retailer', 'distributor'])) continue;

                $sale = Sale::create([
                    'date'           => $row['A'],
                    'sale_type'      => $saleType,
                    'status'         => Sale::Status_Released,
                    'distributor_id' => (int) $row['C'],
                    'retailer_id'    => !empty($row['D']) ? (int) $row['D'] : null,
                    'total_amount'   => 0,
                    'released_datetime' => now(),
                    'released_by_uid'   => Auth::id(),
                ]);

                $qty = (float) ($row['F'] ?? 0);
                $price = (float) ($row['H'] ?? 0);
                $subtotal = round($qty * $price, 2);

                if ($qty <= 0 || $price <= 0 || $subtotal <= 0) {
                    $sale->delete();
                    continue;
                }

                SaleItem::create([
                    'sale_id'    => $sale->id,
                    'product_id' => (int) $row['E'],
                    'quantity'   => $qty,
                    'unit'       => trim($row['G'] ?? ''),
                    'price'      => $price,
                    'subtotal'   => $subtotal,
                ]);
                $sale->update(['total_amount' => $subtotal]);

                $this->adjustStock(
                    $saleType,
                    (int) $row['C'],
                    (int) $row['E'],
                    $qty,
                    null,
                    null,
                    (int) ($row['D'] ?? 0),
                    (string) $row['A'],
                    null,
                    null,
                    Auth::id(),
                    false
                );
                $imported++;
            }
        });

        return response()->json(['message' => "Berhasil mengimpor {$imported} baris."]);
    }
}
