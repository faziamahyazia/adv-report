<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\InventoryLog;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\Sale;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Support\Facades\Auth;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class InventoryLogController extends Controller
{
    use AuthorizesRequests;

    private function isBsRole(?string $role): bool
    {
        return in_array(strtolower((string) $role), [strtolower(User::Role_BS), 'field_officer'], true);
    }

    private function canDeleteInventory(User $user): bool
    {
        return in_array($user->role, [User::Role_Admin, User::Role_Agronomist], true);
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

    private function formatExportQty(float $value): string
    {
        // Format desimal dengan koma tanpa pemisah ribuan.
        // Hanya hilangkan akhiran ",000" sesuai kebutuhan user.
        $formatted = number_format((float) $value, 3, ',', '');

        if (str_ends_with($formatted, ',000')) {
            return substr($formatted, 0, -4);
        }

        return $formatted;
    }

    private function resolveExportQuantity(InventoryLog $item, string $qtyUnit): array
    {
        $unit = $this->normalizeUnit($qtyUnit);
        $product = $item->product;
        $weightGram = (float) ($product->weight ?? 0);

        $qtyKg = (float) ($item->quantity ?? 0);
        $qtyPcs = (float) ($item->base_quantity ?? 0);

        if ($unit === 'pcs') {
            if ($qtyPcs <= 0 && $weightGram > 0 && $qtyKg > 0) {
                $qtyPcs = ($qtyKg * 1000) / $weightGram;
            }
            return [round($qtyPcs, 3), 'pcs'];
        }

        if ($qtyKg <= 0 && $weightGram > 0 && $qtyPcs > 0) {
            $qtyKg = ($qtyPcs * $weightGram) / 1000;
        }

        return [round($qtyKg, 3), 'kg'];
    }

    private function applyInventoryRoleScope($q, User $currentUser): void
    {
        if ($currentUser->role == User::Role_Agronomist) {
            $childBsIds = User::query()
                ->where('parent_id', $currentUser->id)
                ->whereIn('role', [User::Role_BS, 'field_officer'])
                ->pluck('id')
                ->map(fn($id) => (int) $id)
                ->all();

            // IMPORTANT:
            // Keep agronomist + child-BS visibility inside one grouped WHERE,
            // so subsequent filters (checker/product/customer) apply correctly.
            $q->where(function ($query) use ($currentUser, $childBsIds) {
                $query->where('user_id', $currentUser->id);

                if (!empty($childBsIds)) {
                    $query->orWhere(function ($nested) use ($childBsIds) {
                        $nested->whereIn('user_id', $childBsIds)
                            ->orWhereHas('customer', function ($sub) use ($childBsIds) {
                                $sub->whereIn('created_by_uid', $childBsIds)
                                    ->orWhereIn('assigned_user_id', $childBsIds);
                            })
                            ->orWhereIn('reference_sale_id', function ($sub) use ($childBsIds) {
                                $sub->select('id')
                                    ->from((new Sale())->getTable())
                                    ->whereIn('created_by_uid', $childBsIds);
                            });
                    });
                }
            });
        } elseif ($this->isBsRole($currentUser->role)) {
            // BS dapat melihat:
            // 1. Logs yang mereka buat sendiri
            // 2. Logs dari customer yang mereka kelola (sudah assign/buat)
            // 3. Logs hasil rilis sale yang dibuat BS (meski dirilis admin)
            $q->where(function ($query) use ($currentUser) {
                $query->where('user_id', $currentUser->id)
                    ->orWhereHas('customer', function ($sub) use ($currentUser) {
                        $sub->where(function ($scope) use ($currentUser) {
                            $scope->where('created_by_uid', $currentUser->id)
                                ->orWhere('assigned_user_id', $currentUser->id);
                        });
                    })
                    ->orWhereIn('reference_sale_id', function ($sub) use ($currentUser) {
                        $sub->select('id')
                            ->from((new Sale())->getTable())
                            ->where('created_by_uid', $currentUser->id);
                    });
            });
        }
    }

    private function applyInventoryFilters($q, array $filter, ?User $currentUser = null): void
    {
        // Untuk transaksi sale retailer, tampilkan log client tujuan saja.
        // Baris sinkron stok distributor per-sale ([DIST_STOCK_SYNC#...]) disembunyikan dari listing.
        $q->where(function ($query) {
            $query->whereNull('reference_sale_id')
                ->orWhere('notes', 'not like', '[DIST_STOCK_SYNC#%');
        });

        if (!empty($filter['search'])) {
            $search = '%' . $filter['search'] . '%';

            $q->where(function ($query) use ($search) {
                $query->where('area', 'like', $search)
                    ->orWhere('notes', 'like', $search)
                    ->orWhere('lot_package', 'like', $search)
                    ->orWhereHas('product', function ($sub) use ($search) {
                        $sub->where('name', 'like', $search);
                    })
                    ->orWhereHas('product.category', function ($sub) use ($search) {
                        $sub->where('name', 'like', $search);
                    })
                    ->orWhereHas('customer', function ($sub) use ($search) {
                        $sub->where('name', 'like', $search);
                    });
            });
        }

        $isBsFilterBypass = $currentUser && $this->isBsRole($currentUser->role);
        if (!$isBsFilterBypass && !empty($filter['user_id']) && ($filter['user_id'] != 'all')) {
            $selectedUserId = (int) $filter['user_id'];

            // Untuk agronomist, ketika memilih checker BS tertentu,
            // gunakan cakupan BS (user/customer/reference_sale), bukan user_id literal.
            // Ini memastikan log BS yang dirilis admin tetap terlihat saat filter BS dipilih.
            if ($currentUser && $currentUser->role === User::Role_Agronomist) {
                $selectedUser = User::query()
                    ->select(['id', 'role', 'parent_id'])
                    ->find($selectedUserId);

                $isChildBs = $selectedUser
                    && $this->isBsRole($selectedUser->role)
                    && (int) $selectedUser->parent_id === (int) $currentUser->id;

                if ($isChildBs) {
                    $q->where(function ($query) use ($selectedUserId) {
                        $query->where('user_id', $selectedUserId)
                            ->orWhereHas('customer', function ($sub) use ($selectedUserId) {
                                $sub->where('created_by_uid', $selectedUserId)
                                    ->orWhere('assigned_user_id', $selectedUserId);
                            })
                            ->orWhereIn('reference_sale_id', function ($sub) use ($selectedUserId) {
                                $sub->select('id')
                                    ->from((new Sale())->getTable())
                                    ->where('created_by_uid', $selectedUserId);
                            });
                    });

                    // Sudah menerapkan filter checker berbasis BS scope.
                    // Hindari where user_id literal di bawah.
                    $selectedUserId = 0;
                }
            }

            if ($selectedUserId > 0) {
                $q->where('user_id', '=', $selectedUserId);
            }
        }

        if (!empty($filter['product_id']) && ($filter['product_id'] != 'all')) {
            $q->where('product_id', '=', $filter['product_id']);
        }

        if (!empty($filter['customer_id']) && ($filter['customer_id'] != 'all')) {
            $q->where('customer_id', '=', $filter['customer_id']);
        }

        if (!empty($filter['stock_status']) && in_array($filter['stock_status'], ['empty', 'available'], true)) {
            if ($filter['stock_status'] === 'empty') {
                $q->where('quantity', '<=', 0);
            } else {
                $q->where('quantity', '>', 0);
            }
        }
    }

    public function index()
    {
        $current_user = Auth::user();
        $q = User::query();

        if ($this->isBsRole($current_user->role)) {
            // BS hanya melihat dirinya sendiri
            $q->where('id', $current_user->id);
        } elseif ($current_user->role == User::Role_Agronomist) {
            // Agronomist melihat dirinya sendiri + semua BS di bawahnya
            $q->where(function ($query) use ($current_user) {
                $query->where('parent_id', $current_user->id)
                    ->orWhere('id', $current_user->id);
            });
        }

        $users = $q->where('active', true)
            ->orderBy('name')
            ->get();

        return inertia('admin/inventory-log/Index', [
            'products' => Product::orderBy('name', 'asc')->get(['id', 'name']),
            'customers' => $this->getCustomers(),
            'users' => $users,
        ]);
    }

    public function detail($id = 0)
    {
        $item = InventoryLog::with(['product', 'product.category', 'user', 'customer', 'sale.retailer', 'sale.items.product', 'created_by', 'updated_by'])->findOrFail($id);
        // $this->authorize('view', $item);
        return inertia('admin/inventory-log/Detail', [
            'data' => $item,
        ]);
    }

    public function data(Request $request)
    {
        $current_user = Auth::user();

        $orderBy = $request->get('order_by', 'id');
        $orderType = $request->get('order_type', 'desc');
        $filter = $request->get('filter', []);

        $q = InventoryLog::with(['product', 'product.category', 'user', 'customer', 'sale.retailer', 'sale.items.product']);
        $this->applyInventoryRoleScope($q, $current_user);
        $this->applyInventoryFilters($q, $filter, $current_user);

        $q->orderBy($orderBy, $orderType);

        $items = $q->paginate($request->get('per_page', 10))->withQueryString();

        return response()->json($items);
    }

    public function duplicate($id)
    {
        $item = InventoryLog::findOrFail($id);
        $item->id = null;

        $this->authorize('update', $item);

        return inertia('admin/inventory-log/Editor', [
            'data' => $item,
            'categories' => ProductCategory::all(['id', 'name']),
        ]);
    }

    public function editor($id = 0)
    {
        $currentUserId = Auth::user()->id;
        $item = $id ? InventoryLog::findOrFail($id) : new InventoryLog(
            [
                'check_date' => current_date(),
                'user_id' => $currentUserId,
            ]
        );

        $this->authorize('update', $item);

        return inertia('admin/inventory-log/Editor', [
            'data' => $item,
            'products' => Product::orderBy('name', 'asc')->get(['id', 'name', 'weight', 'uom_1', 'uom_2']),
            'customers' => $this->getCustomers(),
            'users' => User::orderBy('name', 'asc')->get(['id', 'name']),
        ]);
    }

    public function save(Request $request)
    {
        $validated = $request->validate([
            'product_id'       => ['required', 'integer', 'exists:products,id'],
            'customer_id'      => ['required', 'integer', 'exists:customers,id'],
            'user_id'          => ['required', 'integer', 'exists:users,id'],
            'check_date'       => ['required', 'date'],
            'area'             => ['required', 'string', 'max:255'],
            'lot_package'      => ['required', 'string', 'max:255'],
            'base_quantity'    => ['required', 'numeric', 'min:0', 'max:999999'],
            'quantity'         => ['required', 'numeric', 'min:0', 'max:999999'],
            'notes'            => ['nullable', 'string'],
        ], [
            'product_id.exists'     => 'Produk yang dipilih tidak ditemukan.',
            'customer_id.exists'    => 'Client yang dipilih tidak ditemukan.',
            'user_id.exists'        => 'Karyawan yang dipilih tidak ditemukan.',
            'check_date.required'   => 'Tanggal pemeriksaan wajib diisi.',
            'base_quantity.between' => 'Jumlah harus bilangan bulat.',
            'base_quantity.required' => 'Jumlah harus diisi.',
            'quantity.between'      => 'Jumlah harus antara 0 hingga 999999.999.',
            'quantity.required'     => 'Jumlah harus diisi.',
            'area.required'         => 'Area harus diisi.',
            'lot_package.required'  => 'Lot package harus diisi.',
        ]);

        $product = Product::findOrFail($validated['product_id']);
        
        // Normalisasi simpanan agar konsisten:
        // - quantity selalu menyimpan uom_1 (primary unit)
        // - base_quantity selalu menyimpan pcs (jika ada konversi kg<->pcs)
        $primaryQty = (float) $validated['base_quantity'];
        $weightGram = (float) ($product->weight ?? 0);
        $uom1 = $this->normalizeUnit($product->uom_1);
        $uom2 = $this->normalizeUnit($product->uom_2);

        if ($uom1 === 'kg' && $uom2 === 'pcs') {
            // Input primary di form adalah kg.
            $validated['quantity'] = round($primaryQty, 3);
            $validated['base_quantity'] = $weightGram > 0
                ? (int) round(($primaryQty * 1000) / $weightGram)
                : (int) round($primaryQty);
        } elseif ($uom1 === 'pcs' && $uom2 === 'kg') {
            // Input primary di form adalah pcs.
            $validated['base_quantity'] = (int) round($primaryQty);
            $validated['quantity'] = $weightGram > 0
                ? round(($validated['base_quantity'] * $weightGram) / 1000, 3)
                : round($primaryQty, 3);
        } else {
            // Fallback produk tanpa pasangan konversi.
            $validated['quantity'] = round($primaryQty, 3);
            $validated['base_quantity'] = (int) round($primaryQty);
        }

        $item = $request->id ? InventoryLog::findOrFail($request->id) : new InventoryLog();

        $this->authorize('update', $item);

        $item->fill($validated);
        $item->save();

        return redirect(route('admin.inventory-log.index'))
            ->with('success', "Log inventori #$item->id telah disimpan.");
    }

    public function updateStock(Request $request, int $id)
    {
        $validated = $request->validate([
            'check_date' => ['required', 'date'],
            'remaining_stock' => ['required', 'numeric', 'min:0', 'max:999999'],
            'remaining_stock_unit' => ['required', 'string', 'max:20'],
        ], [
            'check_date.required' => 'Tanggal update wajib diisi.',
            'remaining_stock.required' => 'Stok tersisa wajib diisi.',
            'remaining_stock_unit.required' => 'Satuan stok wajib dipilih.',
        ]);

        $currentUser = Auth::user();
        $q = InventoryLog::query();
        $this->applyInventoryRoleScope($q, $currentUser);
        $item = $q->findOrFail($id);

        $this->authorize('update', $item);

        $product = Product::findOrFail((int) $item->product_id);
        $uom1 = $this->normalizeUnit($product->uom_1);
        $uom2 = $this->normalizeUnit($product->uom_2);
        $selectedUnit = $this->normalizeUnit($validated['remaining_stock_unit']);
        if ($selectedUnit !== '' && !in_array($selectedUnit, array_filter([$uom1, $uom2]), true)) {
            throw ValidationException::withMessages([
                'remaining_stock_unit' => 'Satuan stok tidak valid untuk produk ini.',
            ]);
        }

        $baseQty = $this->convertToBaseQty($product, (float) $validated['remaining_stock'], $selectedUnit ?: $uom1);
        $weightGram = (float) ($product->weight ?? 0);

        if ($uom1 === 'kg' && $uom2 === 'pcs') {
            $item->quantity = round($baseQty, 3);
            $item->base_quantity = $weightGram > 0
                ? (int) round(($baseQty * 1000) / $weightGram)
                : (int) round($baseQty);
        } elseif ($uom1 === 'pcs' && $uom2 === 'kg') {
            $item->base_quantity = (int) round($baseQty);
            $item->quantity = $weightGram > 0
                ? round(($item->base_quantity * $weightGram) / 1000, 3)
                : round($baseQty, 3);
        } else {
            $item->quantity = round($baseQty, 3);
            $item->base_quantity = (int) round($baseQty);
        }

        $item->check_date = $validated['check_date'];
        $item->save();

        return response()->json([
            'message' => "Stok log inventori #{$item->id} berhasil diperbarui.",
            'updated_datetime' => optional($item->updated_datetime)->toDateTimeString(),
        ]);
    }

    public function delete($id)
    {
        $currentUser = Auth::user();
        if (!$this->canDeleteInventory($currentUser)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat menghapus log inventori.');
        }

        $q = InventoryLog::query();
        $this->applyInventoryRoleScope($q, $currentUser);

        $item = $q->findOrFail($id);
        $item->delete();

        return response()->json([
            'message' => "Log inventori #$item->id telah dihapus."
        ]);
    }

    public function deleteAll(Request $request)
    {
        $currentUser = Auth::user();
        if (!$this->canDeleteInventory($currentUser)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat menghapus semua log inventori.');
        }

        $filter = $request->get('filter', []);

        $q = InventoryLog::query();
        $this->applyInventoryRoleScope($q, $currentUser);
        $this->applyInventoryFilters($q, $filter, $currentUser);

        $total = (int) $q->count();
        if ($total <= 0) {
            return response()->json([
                'message' => 'Tidak ada data log inventori untuk dihapus.',
                'deleted' => 0,
            ]);
        }

        $q->delete();

        return response()->json([
            'message' => "Berhasil menghapus {$total} log inventori.",
            'deleted' => $total,
        ]);
    }

    /**
     * Mengekspor daftar client ke dalam format PDF atau Excel.
     */
    public function export(Request $request)
    {
        $currentUser = Auth::user();
        $filter = (array) $request->get('filter', []);
        $format = strtolower((string) $request->get('format', 'pdf'));
        $qtyUnit = strtolower((string) $request->get('qty_unit', 'kg'));
        if (!in_array($qtyUnit, ['kg', 'pcs'], true)) {
            $qtyUnit = 'kg';
        }

        $q = InventoryLog::with(['product', 'product.category', 'user', 'customer']);
        $this->applyInventoryRoleScope($q, $currentUser);
        $this->applyInventoryFilters($q, $filter, $currentUser);

        $items = $q->orderBy('check_date', 'desc')
            ->orderBy('id', 'desc')
            ->get();

        foreach ($items as $item) {
            [$qtyValue, $qtyLabel] = $this->resolveExportQuantity($item, $qtyUnit);
            $item->export_qty_value = $qtyValue;
            $item->export_qty_unit = $qtyLabel;
            $item->export_qty_text = $this->formatExportQty($qtyValue);
        }

        $title = 'Daftar Log Inventory';
        $filename = 'inventory-log-' . Carbon::now()->format('Ymd_His');

        if ($format === 'pdf') {
            $pdf = Pdf::loadView('export.inventory-log-list-pdf', compact('items', 'title', 'qtyUnit'))
                ->setPaper('a4', 'landscape');
            return $pdf->download($filename . '.pdf');
        }

        if ($format === 'excel') {
            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();
            $sheet->setTitle('Inventory Log');

            // Header
            $sheet->setCellValue('A1', 'No');
            $sheet->setCellValue('B1', 'Tanggal Cek');
            $sheet->setCellValue('C1', 'Checker');
            $sheet->setCellValue('D1', 'Area');
            $sheet->setCellValue('E1', 'Client');
            $sheet->setCellValue('F1', 'Crops');
            $sheet->setCellValue('G1', 'Varietas');
            $sheet->setCellValue('H1', 'LOT Package');
            $sheet->setCellValue('I1', 'Quantity (' . strtoupper($qtyUnit) . ')');
            $sheet->setCellValue('J1', 'Catatan');

            $sheet->getStyle('A1:J1')->getFont()->setBold(true);

            // Data
            $row = 2;
            foreach ($items as $num => $item) {
                $sheet->setCellValue('A' . $row, $num + 1);
                $sheet->setCellValue('B' . $row, optional($item->check_date)->format('d-m-Y'));
                $sheet->setCellValue('C' . $row, $item->user->name ?? '-');
                $sheet->setCellValue('D' . $row, $item->area ?? '-');
                $sheet->setCellValue('E' . $row, $item->customer->name ?? '-');
                $sheet->setCellValue('F' . $row, $item->product->category->name ?? '-');
                $sheet->setCellValue('G' . $row, $item->product->name ?? '-');
                $sheet->setCellValue('H' . $row, $item->lot_package ?? '-');
                $sheet->setCellValue('I' . $row, $item->export_qty_text ?? '-');
                $sheet->setCellValue('J' . $row, $item->notes ?? '-');
                $row++;
            }

            foreach (range('A', 'J') as $column) {
                $sheet->getColumnDimension($column)->setAutoSize(true);
            }

            // Kirim ke memori tanpa menyimpan file
            $response = new StreamedResponse(function () use ($spreadsheet) {
                $writer = new Xlsx($spreadsheet);
                $writer->save('php://output');
            });

            // Atur header response untuk download
            $response->headers->set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            $response->headers->set('Content-Disposition', 'attachment; filename="' . $filename . '.xlsx"');

            return $response;
        }

        return abort(400, 'Format tidak didukung');
    }

    private function getCustomers()
    {
        $currentUser = Auth::user();
        $customersQuery = Customer::query();
        if ($currentUser->role !== User::Role_Admin) {
            $customersQuery->where('assigned_user_id', $currentUser->id);
        }
        return $customersQuery->orderBy('name', 'asc')->get(['id', 'name']);
    }

    public function customersByUser(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
        ]);

        $userId = (int) $request->integer('user_id');

        // Ambil customers yang terkait dengan user ini
        // Either dibuat oleh user atau di-assign ke user
        $customers = Customer::where(function ($q) use ($userId) {
            $q->where('created_by_uid', $userId)
              ->orWhere('assigned_user_id', $userId);
        })
            ->orderBy('name', 'asc')
            ->get(['id', 'name']);

        return response()->json([
            'rows' => $customers->map(fn($c) => [
                'value' => (int) $c->id,
                'label' => $c->name,
            ])->values(),
        ]);
    }
}
