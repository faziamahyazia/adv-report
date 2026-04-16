<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\DistributorTarget;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SaleItem;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class DistributorTargetController extends Controller
{
    public function index(Request $request)
    {
        $initialFiscalYear = (int) $request->get('fiscal_year', $this->defaultFiscalYear());

        return inertia('admin/distributor-target/Index', [
            'distributors' => Customer::where('type', Customer::Type_Distributor)
                ->orderBy('name')
                ->get(['id', 'name']),
            'products' => Product::where('active', true)
                ->orderBy('name')
                ->get(['id', 'name']),
            'month_labels' => DistributorTarget::monthColumns(),
            'initial_fiscal_year' => $initialFiscalYear,
        ]);
    }

    public function editor($id = null)
    {
        $data = null;

        if ($id) {
            if ($this->usesLegacyMonthlySchema()) {
                $base = DistributorTarget::findOrFail($id);
                $monthly = array_fill_keys(array_keys(DistributorTarget::monthColumns()), 0.0);

                $legacyRows = DistributorTarget::query()
                    ->where('distributor_id', $base->distributor_id)
                    ->where('product_id', $base->product_id)
                    ->where('fiscal_year', $base->fiscal_year)
                    ->get(['month', 'target_qty', 'notes']);

                foreach ($legacyRows as $legacyRow) {
                    $column = $this->monthNumberToColumn((int) $legacyRow->month);
                    if ($column) {
                        $monthly[$column] += (float) ($legacyRow->target_qty ?? 0);
                    }
                }

                $data = (object) array_merge([
                    'id' => $base->id,
                    'distributor_id' => $base->distributor_id,
                    'product_id' => $base->product_id,
                    'fiscal_year' => $base->fiscal_year,
                    'notes' => $base->notes,
                    'total_target_qty' => round(array_sum($monthly), 2),
                ], $monthly);
            } else {
                $data = DistributorTarget::with([
                    'distributor:id,name',
                    'product:id,name',
                ])->findOrFail($id);
            }
        }

        return inertia('admin/distributor-target/Editor', [
            'data' => $data,
            'distributors' => Customer::where('type', Customer::Type_Distributor)
                ->orderBy('name')
                ->get(['id', 'name']),
            'products' => Product::where('active', true)
                ->orderBy('name')
                ->get(['id', 'name']),
            'month_labels' => DistributorTarget::monthColumns(),
        ]);
    }

    public function data(Request $request)
    {
        $fiscalYear = (int) $request->get('fiscal_year', $this->defaultFiscalYear());
        $distributorId = $request->integer('distributor_id') ?: null;
        $productId = $request->integer('product_id') ?: null;

        if ($this->usesLegacyMonthlySchema()) {
            return $this->dataFromLegacySchema($fiscalYear, $distributorId, $productId);
        }

        $query = DistributorTarget::with([
            'distributor:id,name',
            'product:id,name,price_1,price_2',
        ])->where('fiscal_year', $fiscalYear);

        if ($distributorId) {
            $query->where('distributor_id', $distributorId);
        }

        if ($productId) {
            $query->where('product_id', $productId);
        }

        $targets = $query->orderBy('distributor_id')->orderBy('product_id')->get();
        $actualMap = $this->buildActualMap($fiscalYear, $distributorId, $productId);
        $monthColumns = array_keys(DistributorTarget::monthColumns());

        $rows = $targets->map(function (DistributorTarget $target) use ($actualMap, $monthColumns) {
            $key = $target->distributor_id . '_' . $target->product_id;
            $actualQty = (float) ($actualMap[$key] ?? 0);
            $productPrice = (float) (($target->product->price_1 ?? 0) ?: ($target->product->price_2 ?? 0));
            $row = [
                'id' => $target->id,
                'key' => $key,
                'fiscal_year' => $target->fiscal_year,
                'distributor_name' => $target->distributor->name ?? '-',
                'product_name' => $target->product->name ?? '-',
                'total_target_qty' => (float) $target->total_target_qty,
                'total_actual_qty' => $actualQty,
                'total_target_value' => round((float) $target->total_target_qty * $productPrice, 2),
                'total_actual_value' => round($actualQty * $productPrice, 2),
                'achievement' => $target->total_target_qty > 0
                    ? round(($actualQty / $target->total_target_qty) * 100, 1)
                    : 0,
                'notes' => $target->notes,
            ];

            foreach ($monthColumns as $monthColumn) {
                $row[$monthColumn] = (float) $target->{$monthColumn};
            }

            return $row;
        })->values();

        return response()->json([
            'rows' => $rows,
            'total_target' => $rows->sum('total_target_qty'),
            'total_actual' => $rows->sum('total_actual_qty'),
            'total_target_value' => $rows->sum('total_target_value'),
            'total_actual_value' => $rows->sum('total_actual_value'),
            'fiscal_year' => $fiscalYear,
        ]);
    }

    public function breakdown($id)
    {
        $target = DistributorTarget::findOrFail($id);
        $monthLabels = DistributorTarget::monthColumns();
        $monthOrder = array_keys($monthLabels);

        $targetByMonth = array_fill_keys($monthOrder, 0.0);

        if ($this->usesLegacyMonthlySchema()) {
            $legacyRows = DistributorTarget::query()
                ->where('distributor_id', $target->distributor_id)
                ->where('product_id', $target->product_id)
                ->where('fiscal_year', $target->fiscal_year)
                ->get(['month', 'target_qty']);

            foreach ($legacyRows as $legacyRow) {
                $column = $this->monthNumberToColumn((int) $legacyRow->month);
                if ($column) {
                    $targetByMonth[$column] += (float) ($legacyRow->target_qty ?? 0);
                }
            }
        } else {
            foreach ($monthOrder as $column) {
                $targetByMonth[$column] = (float) ($target->{$column} ?? 0);
            }
        }

        $price = (float) (($target->product?->price_1 ?? 0) ?: ($target->product?->price_2 ?? 0));
        $fiscalYear = (int) $target->fiscal_year;
        [$startDate, $endDate] = $this->fiscalRange($fiscalYear);

        $actualByMonth = DB::table('sale_items')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->where('sales.distributor_id', $target->distributor_id)
            ->where('sale_items.product_id', $target->product_id)
            ->whereBetween('sales.date', [$startDate, $endDate])
            ->where('sales.sale_type', Sale::Type_Distributor)
            ->where('sales.status', Sale::Status_Released)
            ->selectRaw('MONTH(sales.date) as month_number, SUM(sale_items.quantity) as total_qty')
            ->groupBy(DB::raw('MONTH(sales.date)'))
            ->get()
            ->mapWithKeys(function ($row) {
                return [(int) $row->month_number => (float) $row->total_qty];
            })
            ->all();

        $rows = [];
        foreach ($monthOrder as $column) {
            $monthNumber = (int) $this->columnToMonthNumber($column);
            $actualQty = (float) ($actualByMonth[$monthNumber] ?? 0);
            $targetQty = (float) ($targetByMonth[$column] ?? 0);

            $rows[] = [
                'month_key' => $column,
                'month_label' => $monthLabels[$column] ?? strtoupper(substr($column, 0, 3)),
                'target_qty' => $targetQty,
                'actual_qty' => $actualQty,
                'target_value' => round($targetQty * $price, 2),
                'actual_value' => round($actualQty * $price, 2),
                'achievement' => $targetQty > 0 ? round(($actualQty / $targetQty) * 100, 1) : 0,
            ];
        }

        return response()->json([
            'title' => 'Breakdown Bulanan',
            'subtitle' => ($target->distributor?->name ?? '-') . ' - ' . ($target->product?->name ?? '-') . ' (FY ' . $fiscalYear . '/' . ($fiscalYear + 1) . ')',
            'rows' => $rows,
        ]);
    }

    public function aiBreakdown(Request $request)
    {
        $validated = $request->validate([
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id' => 'required|integer|exists:products,id',
            'fiscal_year' => 'required|integer|min:2020|max:2100',
            'total_target_qty' => 'required|numeric|min:0',
        ]);

        $monthColumns = DistributorTarget::monthColumns();
        $monthKeys = array_keys($monthColumns);
        $previousFiscalYear = (int) $validated['fiscal_year'] - 1;
        [$startDate, $endDate] = $this->fiscalRange($previousFiscalYear);

        $monthlyActual = DB::table('sale_items')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->where('sales.distributor_id', (int) $validated['distributor_id'])
            ->where('sales.sale_type', Sale::Type_Distributor)
            ->where('sales.status', Sale::Status_Released)
            ->whereBetween('sales.date', [$startDate, $endDate])
            ->where('sale_items.product_id', (int) $validated['product_id'])
            ->selectRaw('MONTH(sales.date) as month_number, SUM(sale_items.quantity) as total_qty')
            ->groupBy(DB::raw('MONTH(sales.date)'))
            ->get()
            ->mapWithKeys(fn($row) => [(int) $row->month_number => (float) $row->total_qty])
            ->all();

        $historyStatus = Sale::Status_Released;
        if (array_sum($monthlyActual) <= 0) {
            $monthlyActual = DB::table('sale_items')
                ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
                ->where('sales.distributor_id', (int) $validated['distributor_id'])
                ->where('sales.sale_type', Sale::Type_Distributor)
                ->where('sales.status', 'approved')
                ->whereBetween('sales.date', [$startDate, $endDate])
                ->where('sale_items.product_id', (int) $validated['product_id'])
                ->selectRaw('MONTH(sales.date) as month_number, SUM(sale_items.quantity) as total_qty')
                ->groupBy(DB::raw('MONTH(sales.date)'))
                ->get()
                ->mapWithKeys(fn($row) => [(int) $row->month_number => (float) $row->total_qty])
                ->all();

            if (array_sum($monthlyActual) > 0) {
                $historyStatus = 'approved';
            }
        }

        $weights = [];
        foreach ($monthKeys as $monthKey) {
            $monthNumber = (int) $this->columnToMonthNumber($monthKey);
            $weights[$monthKey] = (float) ($monthlyActual[$monthNumber] ?? 0);
        }

        $weightSum = array_sum($weights);
        $hasHistory = $weightSum > 0;
        if (!$hasHistory) {
            $weights = array_fill_keys($monthKeys, 1.0);
        }

        $monthlyTargets = $this->allocateByWeights((float) $validated['total_target_qty'], $weights);

        return response()->json([
            'mode' => $hasHistory ? 'history_weighted' : 'equal_fallback',
            'message' => $hasHistory
                ? "AI breakdown dibuat berdasarkan pola penjualan FY sebelumnya ({$historyStatus})."
                : 'Data FY sebelumnya tidak ditemukan, fallback ke bagi rata 12 bulan.',
            'monthly_targets' => $monthlyTargets,
            'previous_fiscal_year' => $previousFiscalYear,
            'history_status' => $hasHistory ? $historyStatus : null,
        ]);
    }

    public function export(Request $request)
    {
        $format = strtolower((string) $request->get('format', 'pdf'));

        $response = $this->data($request);
        $payload = $response->getData(true);

        $rows = collect($payload['rows'] ?? []);
        $fiscalYear = (int) ($payload['fiscal_year'] ?? $request->get('fiscal_year', $this->defaultFiscalYear()));
        $monthColumns = DistributorTarget::monthColumns();

        if ($format === 'pdf') {
            $title = "Laporan Target Distributor FY {$fiscalYear}/" . ($fiscalYear + 1);
            $safeFilename = str_replace(['/', '\\'], '-', $title);

            return Pdf::loadView('export.distributor-target-list-pdf', [
                'title' => $title,
                'items' => $rows,
                'month_labels' => $monthColumns,
                'summary' => [
                    'total_target' => (float) ($payload['total_target'] ?? 0),
                    'total_actual' => (float) ($payload['total_actual'] ?? 0),
                    'total_target_value' => (float) ($payload['total_target_value'] ?? 0),
                    'total_actual_value' => (float) ($payload['total_actual_value'] ?? 0),
                ],
            ])->setPaper('a4', 'landscape')
                ->download($safeFilename . '.pdf');
        }

        if ($format === 'excel') {
            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();

            $headers = ['Distributor', 'Produk'];
            foreach ($monthColumns as $label) {
                $headers[] = 'Target ' . $label;
            }
            $headers = array_merge($headers, [
                'Total Target Qty',
                'Total Realisasi Qty',
                'Nilai Target (Rp)',
                'Nilai Realisasi (Rp)',
                'Pencapaian (%)',
                'Catatan',
            ]);

            foreach ($headers as $index => $header) {
                $cell = Coordinate::stringFromColumnIndex($index + 1) . '1';
                $sheet->setCellValue($cell, $header);
            }

            $rowNumber = 2;
            foreach ($rows as $row) {
                $columnNumber = 1;
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, $row['distributor_name'] ?? '-');
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, $row['product_name'] ?? '-');

                foreach (array_keys($monthColumns) as $monthKey) {
                    $sheet->setCellValue(
                        Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber,
                        (float) ($row[$monthKey] ?? 0)
                    );
                }

                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, (float) ($row['total_target_qty'] ?? 0));
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, (float) ($row['total_actual_qty'] ?? 0));
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, (float) ($row['total_target_value'] ?? 0));
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, (float) ($row['total_actual_value'] ?? 0));
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, (float) ($row['achievement'] ?? 0));
                $sheet->setCellValue(Coordinate::stringFromColumnIndex($columnNumber++) . $rowNumber, $row['notes'] ?? '');

                $rowNumber++;
            }

            $title = "Target-Distributor-FY-{$fiscalYear}-" . ($fiscalYear + 1);
            $response = new StreamedResponse(function () use ($spreadsheet) {
                $writer = new Xlsx($spreadsheet);
                $writer->save('php://output');
            });

            $response->headers->set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            $response->headers->set('Content-Disposition', 'attachment; filename="' . $title . '.xlsx"');

            return $response;
        }

        abort(400, "Unknown format {$format}.");
    }

    private function dataFromLegacySchema(int $fiscalYear, ?int $distributorId, ?int $productId)
    {
        $hasActualColumn = Schema::hasColumn('distributor_targets', 'actual_qty');

        $selectColumns = [
            'dt.id',
            'dt.distributor_id',
            'dt.product_id',
            'dt.fiscal_year',
            'dt.month',
            'dt.target_qty',
            'dt.notes',
            'c.name as distributor_name',
            'p.name as product_name',
            'p.price_1 as product_price_1',
            'p.price_2 as product_price_2',
        ];

        if ($hasActualColumn) {
            $selectColumns[] = 'dt.actual_qty';
        }

        $query = DB::table('distributor_targets as dt')
            ->join('customers as c', 'dt.distributor_id', '=', 'c.id')
            ->join('products as p', 'dt.product_id', '=', 'p.id')
            ->where('dt.fiscal_year', $fiscalYear)
            ->select($selectColumns)
            ->orderBy('dt.distributor_id')
            ->orderBy('dt.product_id');

        if ($distributorId) {
            $query->where('dt.distributor_id', $distributorId);
        }

        if ($productId) {
            $query->where('dt.product_id', $productId);
        }

        $records = $query->get();
        $actualMap = $this->buildActualMap($fiscalYear, $distributorId, $productId);
        $monthColumns = array_keys(DistributorTarget::monthColumns());

        $rows = [];
        foreach ($records as $record) {
            $key = $record->distributor_id . '_' . $record->product_id;

            if (!isset($rows[$key])) {
                $rows[$key] = [
                    'id' => $record->id,
                    'key' => $key,
                    'fiscal_year' => (int) $record->fiscal_year,
                    'distributor_name' => $record->distributor_name,
                    'product_name' => $record->product_name,
                    'total_target_qty' => 0,
                    'total_actual_qty' => (float) ($actualMap[$key] ?? 0),
                    'total_target_value' => 0,
                    'total_actual_value' => 0,
                    'imported_actual_qty' => 0,
                    'has_imported_actual' => false,
                    'achievement' => 0,
                    'notes' => $record->notes,
                ];

                foreach ($monthColumns as $monthColumn) {
                    $rows[$key][$monthColumn] = 0;
                }
            }

            $monthColumn = $this->monthNumberToColumn((int) $record->month);
            if ($monthColumn) {
                $rows[$key][$monthColumn] += (float) ($record->target_qty ?? 0);
            }

            $rows[$key]['total_target_qty'] += (float) ($record->target_qty ?? 0);

            $productPrice = (float) (($record->product_price_1 ?? 0) ?: ($record->product_price_2 ?? 0));
            $rows[$key]['total_target_value'] += (float) ($record->target_qty ?? 0) * $productPrice;

            if ($hasActualColumn && isset($record->actual_qty) && $record->actual_qty !== null) {
                $rows[$key]['has_imported_actual'] = true;
                $rows[$key]['imported_actual_qty'] += (float) $record->actual_qty;
                $rows[$key]['total_actual_value'] += (float) $record->actual_qty * $productPrice;
            }
        }

        $rows = collect(array_values($rows))
            ->map(function (array $row) {
                $row['total_target_qty'] = round((float) $row['total_target_qty'], 2);

                // Legacy import actual menjadi fallback jika belum ada realisasi dari penjualan.
                if ($row['has_imported_actual'] && (float) $row['total_actual_qty'] <= 0) {
                    $row['total_actual_qty'] = round((float) $row['imported_actual_qty'], 2);
                }

                $row['total_target_value'] = round((float) $row['total_target_value'], 2);

                $unitPrice = $row['total_target_qty'] > 0
                    ? ((float) $row['total_target_value'] / (float) $row['total_target_qty'])
                    : 0;
                $row['total_actual_value'] = round((float) $row['total_actual_qty'] * $unitPrice, 2);

                $row['achievement'] = $row['total_target_qty'] > 0
                    ? round(($row['total_actual_qty'] / $row['total_target_qty']) * 100, 1)
                    : 0;

                unset($row['imported_actual_qty'], $row['has_imported_actual']);

                return $row;
            })
            ->values();

        return response()->json([
            'rows' => $rows,
            'total_target' => $rows->sum('total_target_qty'),
            'total_actual' => $rows->sum('total_actual_qty'),
            'total_target_value' => $rows->sum('total_target_value'),
            'total_actual_value' => $rows->sum('total_actual_value'),
            'fiscal_year' => $fiscalYear,
        ]);
    }

    public function save(Request $request)
    {
        $validated = $request->validate([
            'id' => 'nullable|integer|exists:distributor_targets,id',
            'distributor_id' => 'required|integer|exists:customers,id',
            'product_id' => 'required|integer|exists:products,id',
            'fiscal_year' => 'required|integer|min:2020|max:2100',
            'notes' => 'nullable|string|max:1000',
            'monthly_targets' => 'required|array|size:12',
            'monthly_targets.apr_qty' => 'required|numeric|min:0',
            'monthly_targets.may_qty' => 'required|numeric|min:0',
            'monthly_targets.jun_qty' => 'required|numeric|min:0',
            'monthly_targets.jul_qty' => 'required|numeric|min:0',
            'monthly_targets.aug_qty' => 'required|numeric|min:0',
            'monthly_targets.sep_qty' => 'required|numeric|min:0',
            'monthly_targets.oct_qty' => 'required|numeric|min:0',
            'monthly_targets.nov_qty' => 'required|numeric|min:0',
            'monthly_targets.dec_qty' => 'required|numeric|min:0',
            'monthly_targets.jan_qty' => 'required|numeric|min:0',
            'monthly_targets.feb_qty' => 'required|numeric|min:0',
            'monthly_targets.mar_qty' => 'required|numeric|min:0',
        ]);

        $monthlyTargets = $this->normalizeMonthlyTargets($validated['monthly_targets']);
        $totalTargetQty = round(array_sum($monthlyTargets), 2);

        if ($this->usesLegacyMonthlySchema()) {
            return $this->saveToLegacySchema($validated, $monthlyTargets);
        }

        $request->validate([
            'fiscal_year' => [
                Rule::unique('distributor_targets')
                    ->ignore($validated['id'] ?? null)
                    ->where(fn($query) => $query
                        ->where('distributor_id', $validated['distributor_id'])
                        ->where('product_id', $validated['product_id'])
                        ->where('fiscal_year', $validated['fiscal_year'])),
            ],
        ], [
            'fiscal_year.unique' => 'Target distributor untuk FY, distributor, dan produk tersebut sudah ada.',
        ]);

        $target = empty($validated['id'])
            ? new DistributorTarget()
            : DistributorTarget::findOrFail($validated['id']);

        $target->distributor_id = $validated['distributor_id'];
        $target->product_id = $validated['product_id'];
        $target->fiscal_year = $validated['fiscal_year'];
        $target->total_target_qty = $totalTargetQty;
        $target->notes = $validated['notes'] ?? null;

        foreach ($monthlyTargets as $column => $value) {
            $target->{$column} = $value;
        }

        $target->save();

        return redirect()
            ->route('admin.distributor-target.index')
            ->with('success', empty($validated['id'])
                ? 'Target distributor berhasil ditambahkan.'
                : 'Target distributor berhasil diperbarui.');
    }

    private function saveToLegacySchema(array $validated, array $monthlyTargets): \Illuminate\Http\RedirectResponse
    {
        $columnToMonth = [
            'apr_qty' => 4,  'may_qty' => 5,  'jun_qty' => 6,
            'jul_qty' => 7,  'aug_qty' => 8,  'sep_qty' => 9,
            'oct_qty' => 10, 'nov_qty' => 11, 'dec_qty' => 12,
            'jan_qty' => 1,  'feb_qty' => 2,  'mar_qty' => 3,
        ];

        $isEdit = !empty($validated['id']);
        $isSameCombo = false;

        if ($isEdit) {
            $original = DistributorTarget::findOrFail($validated['id']);
            $isSameCombo = $original->distributor_id == $validated['distributor_id']
                && $original->product_id == $validated['product_id']
                && $original->fiscal_year == $validated['fiscal_year'];
        }

        if (!$isEdit || !$isSameCombo) {
            $exists = DB::table('distributor_targets')
                ->where('distributor_id', $validated['distributor_id'])
                ->where('product_id', $validated['product_id'])
                ->where('fiscal_year', $validated['fiscal_year'])
                ->exists();

            if ($exists) {
                return back()->withErrors([
                    'fiscal_year' => 'Target distributor untuk FY, distributor, dan produk tersebut sudah ada.',
                ])->withInput();
            }
        }

        $now = now();
        $userId = \Illuminate\Support\Facades\Auth::id();

        DB::table('distributor_targets')
            ->where('distributor_id', $validated['distributor_id'])
            ->where('product_id', $validated['product_id'])
            ->where('fiscal_year', $validated['fiscal_year'])
            ->delete();

        foreach ($monthlyTargets as $column => $value) {
            $month = $columnToMonth[$column] ?? null;
            if ($month === null) continue;

            DB::table('distributor_targets')->insert([
                'distributor_id'   => $validated['distributor_id'],
                'product_id'       => $validated['product_id'],
                'fiscal_year'      => $validated['fiscal_year'],
                'month'            => $month,
                'target_qty'       => $value,
                'notes'            => $validated['notes'] ?? null,
                'created_by_uid'   => $userId,
                'updated_by_uid'   => $userId,
                'created_datetime' => $now,
                'updated_datetime' => $now,
            ]);
        }

        return redirect()
            ->route('admin.distributor-target.index')
            ->with('success', $isEdit
                ? 'Target distributor berhasil diperbarui.'
                : 'Target distributor berhasil ditambahkan.');
    }

    public function delete($id)
    {
        $target = DistributorTarget::findOrFail($id);

        if ($this->usesLegacyMonthlySchema()) {
            DistributorTarget::where('distributor_id', $target->distributor_id)
                ->where('product_id', $target->product_id)
                ->where('fiscal_year', $target->fiscal_year)
                ->delete();
        } else {
            $target->delete();
        }

        return response()->json([
            'message' => 'Target distributor berhasil dihapus.',
        ]);
    }

    private function normalizeMonthlyTargets(array $monthlyTargets): array
    {
        $normalized = [];

        foreach (array_keys(DistributorTarget::monthColumns()) as $column) {
            $normalized[$column] = round((float) ($monthlyTargets[$column] ?? 0), 2);
        }

        return $normalized;
    }

    private function buildActualMap(int $fiscalYear, ?int $distributorId, ?int $productId): array
    {
        [$startDate, $endDate] = $this->fiscalRange($fiscalYear);

        $query = DB::table('sale_items')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->whereBetween('sales.date', [$startDate, $endDate])
            ->where('sales.sale_type', Sale::Type_Distributor)
            ->where('sales.status', Sale::Status_Released)
            ->selectRaw('sales.distributor_id, sale_items.product_id, SUM(sale_items.quantity) as total_qty')
            ->groupBy('sales.distributor_id', 'sale_items.product_id');

        if ($distributorId) {
            $query->where('sales.distributor_id', $distributorId);
        }

        if ($productId) {
            $query->where('sale_items.product_id', $productId);
        }

        return $query->get()
            ->mapWithKeys(fn($row) => [
                $row->distributor_id . '_' . $row->product_id => (float) $row->total_qty,
            ])
            ->all();
    }

    private function fiscalRange(int $fiscalYear): array
    {
        return [
            Carbon::createFromDate($fiscalYear, 4, 1)->startOfDay(),
            Carbon::createFromDate($fiscalYear + 1, 3, 31)->endOfDay(),
        ];
    }

    public function import(Request $request)
    {
        $request->validate([
            'file' => 'required|file|max:5120',
        ]);

        $ext = strtolower($request->file('file')->getClientOriginalExtension());
        if (!in_array($ext, ['csv', 'txt'])) {
            return response()->json(['message' => 'File harus berformat CSV (.csv atau .txt).'], 422);
        }

        $handle = fopen($request->file('file')->getPathname(), 'r');

        // Read and normalise header
        $header = fgetcsv($handle);
        if (!$header) {
            fclose($handle);
            return response()->json(['message' => 'File CSV kosong atau tidak valid.'], 422);
        }
        $header[0] = preg_replace('/^\xEF\xBB\xBF/', '', $header[0]); // strip BOM
        $header = array_map('trim', $header);

        $colIdx = [];
        foreach ($header as $idx => $name) {
            $colIdx[$name] = $idx;
        }

        foreach (['Distributor', 'Tahun Fiskal', 'Varietas', 'Bulan', 'Target'] as $req) {
            if (!array_key_exists($req, $colIdx)) {
                fclose($handle);
                return response()->json(['message' => "Kolom '{$req}' tidak ditemukan di CSV."], 422);
            }
        }

        $actualHeader = null;
        foreach (['Realisasi', 'Realisasi (%)', 'Actual', 'actual'] as $possibleHeader) {
            if (array_key_exists($possibleHeader, $colIdx)) {
                $actualHeader = $possibleHeader;
                break;
            }
        }

        $monthMap = [
            'apr' => ['column' => 'apr_qty', 'number' => 4],
            'april' => ['column' => 'apr_qty', 'number' => 4],
            'mei' => ['column' => 'may_qty', 'number' => 5],
            'may' => ['column' => 'may_qty', 'number' => 5],
            'jun' => ['column' => 'jun_qty', 'number' => 6],
            'juni' => ['column' => 'jun_qty', 'number' => 6],
            'jul' => ['column' => 'jul_qty', 'number' => 7],
            'juli' => ['column' => 'jul_qty', 'number' => 7],
            'agu' => ['column' => 'aug_qty', 'number' => 8],
            'agt' => ['column' => 'aug_qty', 'number' => 8],
            'agustus' => ['column' => 'aug_qty', 'number' => 8],
            'aug' => ['column' => 'aug_qty', 'number' => 8],
            'sep' => ['column' => 'sep_qty', 'number' => 9],
            'sept' => ['column' => 'sep_qty', 'number' => 9],
            'september' => ['column' => 'sep_qty', 'number' => 9],
            'okt' => ['column' => 'oct_qty', 'number' => 10],
            'oct' => ['column' => 'oct_qty', 'number' => 10],
            'oktober' => ['column' => 'oct_qty', 'number' => 10],
            'nov' => ['column' => 'nov_qty', 'number' => 11],
            'november' => ['column' => 'nov_qty', 'number' => 11],
            'des' => ['column' => 'dec_qty', 'number' => 12],
            'dec' => ['column' => 'dec_qty', 'number' => 12],
            'desember' => ['column' => 'dec_qty', 'number' => 12],
            'jan' => ['column' => 'jan_qty', 'number' => 1],
            'januari' => ['column' => 'jan_qty', 'number' => 1],
            'feb' => ['column' => 'feb_qty', 'number' => 2],
            'februari' => ['column' => 'feb_qty', 'number' => 2],
            'mar' => ['column' => 'mar_qty', 'number' => 3],
            'maret' => ['column' => 'mar_qty', 'number' => 3],
            'march' => ['column' => 'mar_qty', 'number' => 3],
        ];

        // Build lookup maps (name -> id, case-insensitive)
        $distributors = Customer::where('type', Customer::Type_Distributor)
            ->get(['id', 'name'])
            ->mapWithKeys(fn($d) => [mb_strtolower(trim($d->name)) => $d->id])
            ->all();

        $products = Product::query()
            ->get(['id', 'name'])
            ->all();

        $productExactMap = [];
        $productNormalizedMap = [];
        foreach ($products as $product) {
            $exactKey = mb_strtolower(trim($product->name));
            if ($exactKey !== '' && !isset($productExactMap[$exactKey])) {
                $productExactMap[$exactKey] = $product->id;
            }

            foreach ($this->buildLookupKeys($product->name) as $lookupKey) {
                if (!isset($productNormalizedMap[$lookupKey])) {
                    $productNormalizedMap[$lookupKey] = $product->id;
                }
            }
        }

        $groups  = [];
        $errors  = [];
        $lineNum = 1;

        while (($row = fgetcsv($handle)) !== false) {
            $lineNum++;

            $distName    = trim($row[$colIdx['Distributor']] ?? '');
            $fyRaw       = trim($row[$colIdx['Tahun Fiskal']] ?? '');
            $productName = trim($row[$colIdx['Varietas']] ?? '');
            $bulan       = trim($row[$colIdx['Bulan']] ?? '');
            $targetQty   = trim($row[$colIdx['Target']] ?? '0');
            $actualQty   = $actualHeader ? trim($row[$colIdx[$actualHeader]] ?? '') : null;

            if ($distName === '' || $fyRaw === '' || $productName === '' || $bulan === '') {
                continue;
            }

            // Fiscal year: take part before "/" to handle typos like "2025/20251"
            $fiscalYear = (int) explode('/', $fyRaw)[0];
            if ($fiscalYear < 2020 || $fiscalYear > 2100) {
                $errors[] = "Baris {$lineNum}: Tahun Fiskal '{$fyRaw}' tidak valid.";
                continue;
            }

            $monthKey = mb_strtolower($bulan);
            if (!isset($monthMap[$monthKey])) {
                $errors[] = "Baris {$lineNum}: Bulan '{$bulan}' tidak dikenali.";
                continue;
            }

            $groupKey = "{$distName}|{$fiscalYear}|{$productName}";
            if (!isset($groups[$groupKey])) {
                $groups[$groupKey] = [
                    'distributor_name' => $distName,
                    'product_name'     => $productName,
                    'fiscal_year'      => $fiscalYear,
                    'target_months'    => [],
                    'actual_months'    => [],
                ];
            }

            $monthColumn = $monthMap[$monthKey]['column'];
            $groups[$groupKey]['target_months'][$monthColumn] = is_numeric($targetQty) ? (float) $targetQty : 0;
            if ($actualHeader) {
                $groups[$groupKey]['actual_months'][$monthColumn] = is_numeric($actualQty) ? (float) $actualQty : 0;
            }
        }

        fclose($handle);

        $created = 0;
        $updated = 0;

        $legacySchema = $this->usesLegacyMonthlySchema();
        $hasActualColumn = Schema::hasColumn('distributor_targets', 'actual_qty');

        foreach ($groups as $group) {
            $distId = $distributors[mb_strtolower(trim($group['distributor_name']))] ?? null;
            if (!$distId) {
                $errors[] = "Distributor '{$group['distributor_name']}' tidak ditemukan di sistem.";
                continue;
            }

            $rawProductName = trim($group['product_name']);
            if (in_array(mb_strtolower($rawProductName), ['n/a', 'na', '-'])) {
                continue;
            }

            $prodId = $productExactMap[mb_strtolower($rawProductName)] ?? null;
            if (!$prodId) {
                foreach ($this->buildLookupKeys($rawProductName) as $lookupKey) {
                    if (isset($productNormalizedMap[$lookupKey])) {
                        $prodId = $productNormalizedMap[$lookupKey];
                        break;
                    }
                }
            }

            if (!$prodId) {
                $errors[] = "Produk '{$group['product_name']}' tidak ditemukan di sistem (FY {$group['fiscal_year']}).";
                continue;
            }

            if ($legacySchema) {
                foreach ($group['target_months'] as $monthColumn => $monthTarget) {
                    $monthNumber = $this->columnToMonthNumber($monthColumn);
                    if (!$monthNumber) {
                        continue;
                    }

                    $attrs = [
                        'distributor_id' => $distId,
                        'product_id'     => $prodId,
                        'fiscal_year'    => $group['fiscal_year'],
                        'month'          => $monthNumber,
                    ];

                    $existing = DistributorTarget::where($attrs)->first();
                    $monthActual = $group['actual_months'][$monthColumn] ?? null;
                    if ($existing) {
                        $existing->target_qty = round((float) $monthTarget, 2);
                        if ($actualHeader && $hasActualColumn) {
                            $existing->actual_qty = round((float) ($monthActual ?? 0), 2);
                        }
                        $existing->save();
                        $updated++;
                    } else {
                        $payload = array_merge($attrs, [
                            'target_qty' => round((float) $monthTarget, 2),
                        ]);
                        if ($actualHeader && $hasActualColumn) {
                            $payload['actual_qty'] = round((float) ($monthActual ?? 0), 2);
                        }
                        DistributorTarget::create($payload);
                        $created++;
                    }

                    if ($actualHeader) {
                        $this->upsertImportedActualSale(
                            distributorId: $distId,
                            productId: $prodId,
                            fiscalYear: (int) $group['fiscal_year'],
                            monthNumber: $monthNumber,
                            actualQty: (float) ($monthActual ?? 0)
                        );
                    }
                }
            } else {
                $allMonths   = array_keys(DistributorTarget::monthColumns());
                $monthValues = [];
                foreach ($allMonths as $col) {
                    $monthValues[$col] = $group['target_months'][$col] ?? 0;
                }
                $monthValues['total_target_qty'] = round(array_sum($monthValues), 2);

                $attrs = [
                    'distributor_id' => $distId,
                    'product_id'     => $prodId,
                    'fiscal_year'    => $group['fiscal_year'],
                ];

                $existing = DistributorTarget::where($attrs)->first();
                if ($existing) {
                    $existing->fill($monthValues)->save();
                    $updated++;
                } else {
                    DistributorTarget::create(array_merge($attrs, $monthValues));
                    $created++;
                }

                if ($actualHeader) {
                    foreach ($group['target_months'] as $monthColumn => $monthTarget) {
                        $monthNumber = $this->columnToMonthNumber($monthColumn);
                        if (!$monthNumber) {
                            continue;
                        }

                        $this->upsertImportedActualSale(
                            distributorId: $distId,
                            productId: $prodId,
                            fiscalYear: (int) $group['fiscal_year'],
                            monthNumber: $monthNumber,
                            actualQty: (float) ($group['actual_months'][$monthColumn] ?? 0)
                        );
                    }
                }
            }
        }

        return response()->json([
            'success' => $created + $updated,
            'created' => $created,
            'updated' => $updated,
            'errors'  => $errors,
        ]);
    }

    private function usesLegacyMonthlySchema(): bool
    {
        $columns = Schema::getColumnListing('distributor_targets');
        return in_array('month', $columns) && in_array('target_qty', $columns) && !in_array('apr_qty', $columns);
    }

    private function monthNumberToColumn(int $month): ?string
    {
        return [
            4 => 'apr_qty',
            5 => 'may_qty',
            6 => 'jun_qty',
            7 => 'jul_qty',
            8 => 'aug_qty',
            9 => 'sep_qty',
            10 => 'oct_qty',
            11 => 'nov_qty',
            12 => 'dec_qty',
            1 => 'jan_qty',
            2 => 'feb_qty',
            3 => 'mar_qty',
        ][$month] ?? null;
    }

    private function columnToMonthNumber(string $column): ?int
    {
        return [
            'apr_qty' => 4,
            'may_qty' => 5,
            'jun_qty' => 6,
            'jul_qty' => 7,
            'aug_qty' => 8,
            'sep_qty' => 9,
            'oct_qty' => 10,
            'nov_qty' => 11,
            'dec_qty' => 12,
            'jan_qty' => 1,
            'feb_qty' => 2,
            'mar_qty' => 3,
        ][$column] ?? null;
    }

    private function buildLookupKeys(string $name): array
    {
        $name = mb_strtolower(trim($name));
        $spaced = preg_replace('/[^\pL\pN]+/u', ' ', $name);
        $spaced = trim(preg_replace('/\s+/', ' ', $spaced));
        if ($spaced === '') {
            return [];
        }

        $tokens = array_values(array_filter(explode(' ', $spaced), fn($token) => $token !== ''));

        $removeWords = ['f1', 'f2', 'adv'];
        $tokensNoWord = array_values(array_filter($tokens, fn($token) => !in_array($token, $removeWords, true)));
        $tokensNoNumber = array_values(array_filter($tokensNoWord, fn($token) => !preg_match('/^\d+$/', $token)));

        $keys = [
            implode(' ', $tokens),
            implode('', $tokens),
            implode(' ', $tokensNoWord),
            implode('', $tokensNoWord),
            implode(' ', $tokensNoNumber),
            implode('', $tokensNoNumber),
        ];

        return array_values(array_unique(array_filter($keys, fn($key) => $key !== '')));
    }

    private function upsertImportedActualSale(int $distributorId, int $productId, int $fiscalYear, int $monthNumber, float $actualQty): void
    {
        $year = $monthNumber >= 4 ? $fiscalYear : ($fiscalYear + 1);
        $date = Carbon::createFromDate($year, $monthNumber, 1)->endOfMonth()->toDateString();
        $actualQty = round($actualQty, 2);
        $product = Product::find($productId);
        $price = (float) (($product?->price_1 ?? 0) ?: ($product?->price_2 ?? 0));
        $subtotal = round($actualQty * $price, 2);

        $noteTag = "[TARGET_IMPORT] FY{$fiscalYear}-M{$monthNumber}-P{$productId}";

        $sale = Sale::where('sale_type', Sale::Type_Retailer)
            ->where('distributor_id', $distributorId)
            ->whereDate('date', $date)
            ->where('notes', $noteTag)
            ->first();

        if (!$sale) {
            $sale = Sale::create([
                'date' => $date,
                'sale_type' => Sale::Type_Retailer,
                'distributor_id' => $distributorId,
                'retailer_id' => null,
                'notes' => $noteTag,
                'total_amount' => 0,
            ]);
        }

        $item = SaleItem::where('sale_id', $sale->id)
            ->where('product_id', $productId)
            ->first();

        if ($item) {
            $item->quantity = $actualQty;
            $item->unit = $item->unit ?: '';
            $item->price = $price;
            $item->subtotal = $subtotal;
            $item->save();
        } else {
            SaleItem::create([
                'sale_id' => $sale->id,
                'product_id' => $productId,
                'quantity' => $actualQty,
                'unit' => '',
                'price' => $price,
                'subtotal' => $subtotal,
            ]);
        }

        $sale->total_amount = $subtotal;
        $sale->save();
    }

    private function allocateByWeights(float $totalQty, array $weights): array
    {
        $keys = array_keys($weights);
        $totalQtyCents = (int) round(max(0, $totalQty) * 100);

        if ($totalQtyCents <= 0 || count($keys) === 0) {
            return array_fill_keys($keys, 0.0);
        }

        $weightSum = array_sum($weights);
        if ($weightSum <= 0) {
            $weights = array_fill_keys($keys, 1.0);
            $weightSum = (float) count($keys);
        }

        $allocation = [];
        $remainders = [];
        $allocatedCents = 0;

        foreach ($keys as $key) {
            $exact = ((float) ($weights[$key] ?? 0) / $weightSum) * $totalQtyCents;
            $base = (int) floor($exact);
            $allocation[$key] = $base;
            $remainders[$key] = $exact - $base;
            $allocatedCents += $base;
        }

        $remaining = $totalQtyCents - $allocatedCents;
        if ($remaining > 0) {
            arsort($remainders);
            foreach ($remainders as $key => $remainder) {
                if ($remaining <= 0) {
                    break;
                }
                $allocation[$key] += 1;
                $remaining--;
            }
        }

        $result = [];
        foreach ($keys as $key) {
            $result[$key] = round(((int) ($allocation[$key] ?? 0)) / 100, 2);
        }

        return $result;
    }

    private function defaultFiscalYear(): int
    {
        return now()->month >= 4 ? now()->year : now()->year - 1;
    }
}