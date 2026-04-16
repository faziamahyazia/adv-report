<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Activity;
use App\Models\ActivityPlan;
use App\Models\ActivityTarget;
use App\Models\ActivityType;
use App\Models\DemoPlot;
use App\Models\InventoryLog;
use App\Models\Product;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    private function formatExportQty(float $value): string
    {
        // Format desimal dengan koma tanpa pemisah ribuan.
        // Hanya hilangkan akhiran ",000" agar nilai seperti 3,080 tetap utuh.
        $formatted = number_format((float) $value, 3, ',', '');

        if (str_ends_with($formatted, ',000')) {
            return substr($formatted, 0, -4);
        }

        return $formatted;
    }

    private function resolveInventoryQty(InventoryLog $item, string $qtyUnit): float
    {
        $unit = strtolower(trim((string) $qtyUnit));
        $weightGram = (float) ($item->product->weight ?? 0);

        $qtyKg = (float) ($item->quantity ?? 0);
        $qtyPcs = (float) ($item->base_quantity ?? 0);

        if ($unit === 'pcs') {
            if ($qtyPcs <= 0 && $weightGram > 0 && $qtyKg > 0) {
                $qtyPcs = ($qtyKg * 1000) / $weightGram;
            }

            return round($qtyPcs, 3);
        }

        if ($qtyKg <= 0 && $weightGram > 0 && $qtyPcs > 0) {
            $qtyKg = ($qtyPcs * $weightGram) / 1000;
        }

        return round($qtyKg, 3);
    }

    public function index(Request $request)
    {
        $type = $request->get('report_type');

        $currentUser = Auth::user();
        $users = [];
        if ($currentUser->role == User::Role_Agronomist) {
            $users = User::query()->where('role', '=', User::Role_BS)
                ->where('parent_id', '=', $currentUser->id)
                ->orWhere('id', '=', $currentUser->id)
                ->orderBy('name', 'asc')
                ->get();
        } else if ($currentUser->role == User::Role_Admin) {
            $users = User::query()->orderBy('name', 'asc')->get();
        }

        return inertia('admin/report/Index', [
            'report_type' => $type,
            'users' => $users,
            'products' => Product::where('active', true)
                ->orderBy('name')
                ->select('id', 'name')
                ->get(),
        ]);
    }

    public function demoPlotDetail(Request $request)
    {
        $user_id = $request->get('user_id');

        if (isset($user_id)) {
            $current_user = Auth::user();

            $q = DemoPlot::select('demo_plots.*')
                ->leftJoin('users', 'users.id', '=', 'demo_plots.user_id')
                ->leftJoin('products', 'products.id', '=', 'demo_plots.product_id')
                ->with([
                    'user:id,username,name',
                    'product:id,name',
                ]);

            if ($current_user->role == User::Role_Agronomist) {
                if ($user_id == 'all') {
                    $q->whereHas('user', function ($query) use ($current_user) {
                        $query->where('parent_id', $current_user->id);
                    });
                } else {
                    $q->where('demo_plots.user_id', $user_id);
                }
            } else if ($current_user->role == User::Role_Admin) {
                if ($user_id != 'all') {
                    $q->where('demo_plots.user_id', $user_id);
                }
            }

            $items = $q->where('demo_plots.active', true)
                ->orderBy('users.name', 'asc')
                ->orderBy('products.name', 'asc')
                ->get();

            [$title, $user] = $this->resolveTitle('Laporan Demo Plot', $user_id);

            return $this->generatePdfReport('report.demo-plot-detail', 'landscape', compact(
                'items',
                'title',
                'user'
            ));
        }
    }

    public function demoPlotWithPhoto(Request $request)
    {
        $user_id = $request->get('user_id');

        if (isset($user_id)) {
            ini_set('memory_limit', '512M');
            set_time_limit(120);

            $current_user = Auth::user();

            $q = DemoPlot::select('demo_plots.*')
                ->addSelect('latest_visits.image_path as latest_image_path')
                ->leftJoin('users', 'users.id', '=', 'demo_plots.user_id')
                ->leftJoin('products', 'products.id', '=', 'demo_plots.product_id')
                ->leftJoin(
                    DB::raw('
                        (
                            SELECT dpv.demo_plot_id, dpv.image_path
                            FROM demo_plot_visits dpv
                            INNER JOIN (
                                SELECT demo_plot_id, MAX(id) AS latest_id
                                FROM demo_plot_visits
                                WHERE image_path IS NOT NULL AND image_path <> ""
                                GROUP BY demo_plot_id
                            ) latest ON latest.latest_id = dpv.id
                            WHERE dpv.image_path IS NOT NULL AND dpv.image_path <> ""
                        ) AS latest_visits
                    '),
                    'latest_visits.demo_plot_id',
                    '=',
                    'demo_plots.id'
                )
                ->with([
                    'user:id,username,name',
                    'product:id,name',
                ]);

            if ($current_user->role == User::Role_Agronomist) {
                if ($user_id == 'all') {
                    $q->whereHas('user', function ($query) use ($current_user) {
                        $query->where('parent_id', $current_user->id);
                    });
                } else {
                    $q->where('demo_plots.user_id', $user_id);
                }
            } else if ($current_user->role == User::Role_Admin) {
                if ($user_id != 'all') {
                    $q->where('demo_plots.user_id', $user_id);
                }
            }

            $items = $q->where('demo_plots.active', true)
                ->orderBy('users.name', 'asc')
                ->orderBy('products.name', 'asc')
                ->get();

            $subtitles = [];
            if ($user_id == 'all') {
                $maxPhotoRows = max(20, min(300, (int) $request->get('max_photo_rows', 120)));
                foreach ($items as $index => $item) {
                    $item->pdf_disable_image = $index >= $maxPhotoRows;
                }

                if ($items->count() > $maxPhotoRows) {
                    $subtitles[] = 'Catatan: Foto ditampilkan maksimal ' . $maxPhotoRows . ' baris pertama untuk menjaga performa export.';
                }
            }

            [$title, $user] = $this->resolveTitle('Laporan Foto Demo Plot', $user_id);

            return $this->generatePdfReport('report.demo-plot-with-photo', 'landscape', compact(
                'items',
                'title',
                'user',
                'subtitles'
            ));
        }
    }

    public function newDemoPlotDetail(Request $request)
    {
        [$start_date, $end_date] = resolve_period(
            $request->get('period'),
            $request->get('start_date'),
            $request->get('end_date')
        );
        $user_id = $request->get('user_id');

        if (isset($user_id)) {
            $current_user = Auth::user();

            $q = DemoPlot::select('demo_plots.*')
                ->leftJoin('users', 'users.id', '=', 'demo_plots.user_id')
                ->leftJoin('products', 'products.id', '=', 'demo_plots.product_id')
                ->with([
                    'user:id,username,name',
                    'product:id,name',
                ]);

            if ($current_user->role == User::Role_Agronomist) {
                if ($user_id == 'all') {
                    $q->whereHas('user', function ($query) use ($current_user) {
                        $query->where('parent_id', $current_user->id);
                    });
                } else {
                    $q->where('demo_plots.user_id', $user_id);
                }
            }

            $plantStatusSubtitle = 'Status Tanaman: ';
            $plant_statuses = $request->get("plant_statuses", "all");
            if (!empty($plant_statuses)) {
                $status = explode(',', $plant_statuses);
                $q->whereIn('demo_plots.plant_status', $status);

                $statusLabels = [];
                foreach ($status as $statusKey) {
                    $statusLabels[] = DemoPlot::PlantStatuses[$statusKey];
                }
                $plantStatusSubtitle .= implode(', ', $statusLabels);
            } else {
                $plantStatusSubtitle .= 'Semua';
            }

            $items = $q->where('demo_plots.active', true)
                ->whereBetween('plant_date', [$start_date, $end_date])
                ->orderBy('users.name', 'asc')
                ->orderBy('products.name', 'asc')
                ->get();

            $format = $request->get('format', 'pdf');
            [$title, $user] = $this->resolveTitle('Laporan Demo Plot Baru', $user_id);
            $subtitles = [
                $plantStatusSubtitle
            ];
            return $this->generatePdfReport('report.new-demo-plot-detail', 'landscape', compact(
                'items',
                'title',
                'user',
                'subtitles',
                'start_date',
                'end_date',
            ));
        }
    }

    public function clientActualInventory(Request $request)
    {
        $userId = $request->get('user_id');
        $productId = $request->get('product_id');
        $qtyUnit = strtolower((string) $request->get('qty_unit', 'kg'));
        if (!in_array($qtyUnit, ['kg', 'pcs'], true)) {
            $qtyUnit = 'kg';
        }
        $currentUser = Auth::user();

        // 1. Buat subquery untuk mendapatkan tanggal pemeriksaan (check_date) terbaru untuk setiap grup
        $latestCheckDateSubQuery = InventoryLog::select(
            'product_id',
            'customer_id',
            'lot_package',
            DB::raw('MAX(check_date) as latest_date')
        )
            // Terapkan filter user_id dan product_id secara opsional di sini
            ->when($userId && $userId !== 'all', function ($query) use ($userId) {
                return $query->where('user_id', $userId);
            })
            ->when($productId && $productId !== 'all', function ($query) use ($productId) {
                return $query->where('product_id', $productId);
            })
            ->groupBy('product_id', 'customer_id', 'lot_package');

        // Logika tambahan untuk peran Agronomist
        if ($currentUser->role == User::Role_Agronomist) {
            // Ambil semua user_id bawahan dari parent_id yang sesuai
            $childUserIds = User::where('parent_id', $currentUser->id)->pluck('id');

            // Tambahkan user_id BS itu sendiri ke dalam daftar
            $childUserIds->push($currentUser->id);

            // Tambahkan klausa 'whereIn' untuk memfilter berdasarkan user_id bawahan
            $latestCheckDateSubQuery->whereIn('user_id', $childUserIds);
        }

        // 2. Buat subquery utama untuk mendapatkan ID terakhir dari entri dengan check_date terbaru
        $latestIdSubQuery = InventoryLog::select(DB::raw('MAX(id) as max_id'))
            ->joinSub($latestCheckDateSubQuery, 't_latest_date', function ($join) {
                $join->on('inventory_logs.product_id', '=', 't_latest_date.product_id')
                    ->on('inventory_logs.customer_id', '=', 't_latest_date.customer_id')
                    ->on('inventory_logs.lot_package', '=', 't_latest_date.lot_package')
                    ->on('inventory_logs.check_date', '=', 't_latest_date.latest_date');
            })
            ->groupBy('inventory_logs.product_id', 'inventory_logs.customer_id', 'inventory_logs.lot_package');

        // 3. Jalankan query utama untuk mendapatkan data final
        $items = InventoryLog::from('inventory_logs as t1')
            ->joinSub($latestIdSubQuery, 't_latest_id', function ($join) {
                $join->on('t1.id', '=', 't_latest_id.max_id');
            })
            ->where('t1.quantity', '>', 0)
            ->orderBy('t1.user_id')
            ->orderBy('t1.customer_id')
            ->orderBy('t1.product_id')
            ->get();

        foreach ($items as $item) {
            $item->export_qty_value = $this->resolveInventoryQty($item, $qtyUnit);
            $item->export_qty_text = $this->formatExportQty((float) $item->export_qty_value);
        }

        [$title, $user, $product] = $this->resolveTitle('Laporan Inventori Aktual', $userId, $productId);
        $format = $request->get('format', 'pdf');

        if ($format === 'pdf') {
            return $this->generatePdfReport('report.client-actual-inventory', 'landscape', compact(
                'items',
                'title',
                'user',
                'product',
                'qtyUnit',
            ));
        } else if ($format === 'excel') {
            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();

            // Tambahkan header
            $sheet->setCellValue('A1', 'Area');
            $sheet->setCellValue('B1', 'Crops');
            $sheet->setCellValue('C1', 'Checker');
            $sheet->setCellValue('D1', 'Kiosk/Distributor');
            $sheet->setCellValue('E1', 'Hybrid');
            $sheet->setCellValue('F1', 'Check Date');
            $sheet->setCellValue('G1', 'Lot Package');
            $sheet->setCellValue('H1', 'Qty (' . strtoupper($qtyUnit) . ')');

            // Tambahkan data ke Excel
            $row = 2;
            foreach ($items as $num => $item) {
                $sheet->setCellValue('A' . $row, $item->area);
                $sheet->setCellValue('B' . $row, $item->product->category->name);
                $sheet->setCellValue('C' . $row, $item->user->name);
                $sheet->setCellValue('D' . $row, $item->customer->name);
                $sheet->setCellValue('E' . $row, $item->product->name);
                $sheet->setCellValue('F' . $row, format_date($item->check_date));
                $sheet->setCellValue('G' . $row, $item->lot_package);
                $sheet->setCellValue('H' . $row, $item->export_qty_text);
                $row++;
            }

            // Kirim ke memori tanpa menyimpan file
            $response = new StreamedResponse(function () use ($spreadsheet) {
                $writer = new Xlsx($spreadsheet);
                $writer->save('php://output');
            });

            $filename = $title . ' - ' . env('APP_NAME') . Carbon::now()->format('dmY_His');

            // Atur header response untuk download
            $response->headers->set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            $response->headers->set('Content-Disposition', 'attachment; filename="' . $filename . '.xlsx"');

            return $response;
        }

        abort(400, "Unknown format $format.");
    }

    public function activityPlanDetail(Request $request)
    {
        [$start_date, $end_date] = resolve_period(
            $request->get('period'),
            $request->get('start_date'),
            $request->get('end_date')
        );

        $user_id = $request->get('user_id');
        if (!isset($user_id)) {
            abort(400, 'Parameter user_id wajib diisi.');
        }

        $current_user = Auth::user();

        $q = DB::table('activity_plan_details as apd')
            ->join('activity_plans as ap', 'ap.id', '=', 'apd.parent_id')
            ->join('users as u', 'u.id', '=', 'ap.user_id')
            ->leftJoin('activity_types as at', 'at.id', '=', 'apd.type_id')
            ->leftJoin('products as p', 'p.id', '=', 'apd.product_id')
            ->select([
                'apd.date',
                'u.name as bs_name',
                'at.name as activity_type',
                'p.name as product_name',
                'apd.location',
                'apd.cost',
                'ap.status',
                'apd.notes',
            ])
            ->whereBetween('apd.date', [$start_date, $end_date]);

        if ($current_user->role == User::Role_Agronomist) {
            if ($user_id == 'all') {
                $q->where('u.parent_id', $current_user->id);
            } else {
                $q->where('ap.user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_Admin) {
            if ($user_id != 'all') {
                $q->where('ap.user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_BS) {
            $q->where('ap.user_id', $current_user->id);
        }

        $items = $q->orderBy('u.name', 'asc')
            ->orderBy('apd.date', 'asc')
            ->get();

        [$title, $user] = $this->resolveTitle('Laporan Rencana Kegiatan', $user_id);
        $subtitles = [
            'Periode: ' . format_date($start_date) . ' s/d ' . format_date($end_date),
        ];

        return $this->generatePdfReport('export.activity-plan-list-pdf', 'landscape', compact(
            'items',
            'title',
            'user',
            'subtitles',
            'start_date',
            'end_date'
        ));
    }

    public function activityRealizationDetail(Request $request)
    {
        [$start_date, $end_date] = resolve_period(
            $request->get('period'),
            $request->get('start_date'),
            $request->get('end_date')
        );

        $user_id = $request->get('user_id');
        if (!isset($user_id)) {
            abort(400, 'Parameter user_id wajib diisi.');
        }

        $current_user = Auth::user();

        $q = Activity::with([
            'type:id,name',
            'user:id,name,parent_id',
            'product:id,name',
        ])->whereBetween('date', [$start_date, $end_date]);

        if ($current_user->role == User::Role_Agronomist) {
            if ($user_id == 'all') {
                $q->whereHas('user', function ($query) use ($current_user) {
                    $query->where('parent_id', $current_user->id);
                });
            } else {
                $q->where('user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_Admin) {
            if ($user_id != 'all') {
                $q->where('user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_BS) {
            $q->where('user_id', $current_user->id);
        }

        $items = $q->orderBy('date', 'asc')
            ->orderBy('id', 'asc')
            ->get();

        [$title, $user] = $this->resolveTitle('Laporan Realisasi Kegiatan', $user_id);
        $subtitles = [
            'Periode: ' . format_date($start_date) . ' s/d ' . format_date($end_date),
        ];

        return $this->generatePdfReport('export.activity-list-pdf', 'landscape', compact(
            'items',
            'title',
            'user',
            'subtitles',
            'start_date',
            'end_date'
        ));
    }

    public function distributorTargetDetail(Request $request)
    {
        $fiscalYear = (int) $request->get(
            'fiscal_year',
            now()->month >= 4 ? now()->year : (now()->year - 1)
        );

        $format = strtolower((string) $request->get('format', 'pdf'));

        return redirect()->route('admin.distributor-target.export', [
            'format' => in_array($format, ['pdf', 'excel'], true) ? $format : 'pdf',
            'fiscal_year' => $fiscalYear,
        ]);
    }

    public function activiyTargetDetail(Request $request)
    {
        [$start_date, $end_date] = resolve_period(
            $request->get('period'),
            $request->get('start_date'),
            $request->get('end_date')
        );

        $user_id = $request->get('user_id');
        if (!isset($user_id)) {
            abort(400, 'Parameter user_id wajib diisi.');
        }

        $current_user = Auth::user();
        $types = ActivityType::where('active', true)
            ->select(['id', 'name', 'weight'])
            ->orderBy('name', 'asc')
            ->get();

        $q = ActivityTarget::with([
            'user:id,username,name,parent_id',
            'details',
            'details.type:id,name',
        ]);

        if ($current_user->role == User::Role_Agronomist) {
            $q->whereHas('user', function ($qq) use ($current_user) {
                $qq->where('parent_id', $current_user->id);
            });
            if ($user_id != 'all') {
                $q->where('user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_Admin) {
            if ($user_id != 'all') {
                $q->where('user_id', $user_id);
            }
        } else if ($current_user->role == User::Role_BS) {
            $q->where('user_id', $current_user->id);
        }

        $targets = $q->orderBy('year', 'desc')->orderBy('quarter', 'desc')->get();

        $fiscalQuarterMonths = [
            1 => [4, 5, 6],
            2 => [7, 8, 9],
            3 => [10, 11, 12],
            4 => [1, 2, 3],
        ];

        $startDate = Carbon::parse($start_date)->startOfDay();
        $endDate = Carbon::parse($end_date)->endOfDay();

        $items = [];
        foreach ($targets as $target) {
            $months = $fiscalQuarterMonths[$target->quarter] ?? null;
            if (!$months) {
                continue;
            }

            $startYear = ($target->quarter == 4) ? $target->year + 1 : $target->year;
            $quarterStart = Carbon::createFromDate($startYear, $months[0], 1)->startOfDay();
            $quarterEnd = Carbon::createFromDate($startYear, $months[2], 1)->endOfMonth()->endOfDay();

            if ($quarterEnd->lt($startDate) || $quarterStart->gt($endDate)) {
                continue;
            }

            $targetsByType = [];
            foreach ($target->details as $detail) {
                $typeId = (int) $detail->type_id;
                if (!isset($targetsByType[$typeId])) {
                    $targetsByType[$typeId] = [
                        'quarter_qty' => (int) $detail->quarter_qty,
                        'month1_qty' => (int) $detail->month1_qty,
                        'month2_qty' => (int) $detail->month2_qty,
                        'month3_qty' => (int) $detail->month3_qty,
                    ];
                }
            }

            $activities = Activity::query()
                ->where('user_id', $target->user_id)
                ->where('status', Activity::Status_Approved)
                ->whereBetween('date', [$quarterStart, $quarterEnd])
                ->get();

            $activitiesByType = [];
            foreach ($activities as $activity) {
                $activityMonth = Carbon::parse($activity->date)->month;
                $monthIndex = array_search($activityMonth, $months);
                if ($monthIndex === false) {
                    continue;
                }

                $typeId = (int) $activity->type_id;
                if (!isset($activitiesByType[$typeId])) {
                    $activitiesByType[$typeId] = [
                        'quarter_qty' => 0,
                        'month1_qty' => 0,
                        'month2_qty' => 0,
                        'month3_qty' => 0,
                    ];
                }

                $activitiesByType[$typeId]['quarter_qty'] += 1;
                $monthKey = 'month' . ($monthIndex + 1) . '_qty';
                $activitiesByType[$typeId][$monthKey] += 1;
            }

            $items[] = [
                'id' => $target->id,
                'user' => [
                    'id' => $target->user->id,
                    'name' => $target->user->name,
                    'username' => $target->user->username,
                ],
                'targets' => $targetsByType,
                'activities' => $activitiesByType,
            ];
        }

        [$title, $user] = $this->resolveTitle('Laporan KPI Kegiatan', $user_id);
        $subtitles = [
            'Periode: ' . format_date($start_date) . ' s/d ' . format_date($end_date),
        ];

        return $this->generatePdfReport('export.activity-target-list-pdf', 'portrait', compact(
            'items',
            'title',
            'user',
            'types',
            'subtitles',
            'start_date',
            'end_date'
        ));
    }

    protected function resolveTitle(string $baseTitle, $user_id, $product_id = 'all'): array
    {
        $user = null;
        if ($user_id !== 'all') {
            $user = User::find($user_id);
            $title = "$baseTitle - $user->name ($user->username)";
        } else {
            $title = "$baseTitle - All BS";
        }

        $product = null;
        if ($product_id !== 'all') {
            $product = Product::find($product_id);
            $title .= ' - ' . $product->name;
        } else {
            $title .= ' - All Varietas';
        }

        return [$title, $user, $product];
    }


    protected function generatePdfReport($view, $orientation, $data, $response = 'pdf')
    {
        $filename = env('APP_NAME') . ' - ' . $data['title'];

        if (isset($data['start_date']) || isset($data['end_date'])) {
            if (empty($data['subtitles'])) {
                $data['subtitles'] = [];
            }
            $data['subtitles'][] = 'Periode: ' . format_date($data['start_date']) . ' s/d ' . format_date($data['end_date']);
        }

        if ($response == 'pdf') {
            return Pdf::loadView($view, $data)
                ->setPaper('a4', $orientation)
                ->download($filename . '.pdf');
        }

        if ($response == 'html') {
            return view($view, $data);
        }

        throw new Exception('Unknown response type!');
    }
}
