<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\ComplaintImage;
use App\Models\ComplaintLog;
use App\Models\Product;
use App\Models\ProductBatch;
use App\Models\SaleItem;
use App\Models\User;
use App\Services\FonteWhatsAppService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Intervention\Image\ImageManager;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ComplaintController extends Controller
{
    public function index()
    {
        return inertia('admin/complaint/Index', [
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name', 'uom_1', 'uom_2', 'weight']),
            'batches' => ProductBatch::orderByDesc('id')->limit(500)->get(['id', 'product_id', 'product_name', 'batch_number', 'production_date', 'distribution_area']),
            'bs_users' => User::where('role', User::Role_BS)->where('active', true)->orderBy('name')->get(['id', 'name', 'username', 'parent_id']),
        ]);
    }

    public function analytics()
    {
        return inertia('admin/complaint/Analytics', [
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
            'bs_users' => User::where('role', User::Role_BS)->where('active', true)->orderBy('name')->get(['id', 'name', 'username', 'parent_id']),
        ]);
    }

    public function editor($id = 0)
    {
        $user = Auth::user();
        $item = $id ? Complaint::with(['images'])->findOrFail($id) : new Complaint([
            'bs_id' => $user->role === User::Role_BS ? $user->id : null,
            'severity' => Complaint::Severity_Medium,
            'category' => Complaint::Category_RebahSemai,
            'status' => Complaint::Status_Open,
            'source' => 'online',
        ]);

        $this->authorizeComplaint($item, true);

        return inertia('admin/complaint/Editor', [
            'data' => $item,
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
            'batches' => ProductBatch::orderByDesc('id')->limit(800)->get(['id', 'product_id', 'product_name', 'batch_number', 'production_date', 'distribution_area']),
            'bs_users' => User::where('role', User::Role_BS)->where('active', true)->orderBy('name')->get(['id', 'name', 'username', 'parent_id']),
        ]);
    }

    public function detail($id)
    {
        $item = Complaint::with([
            'product:id,name',
            'batch:id,product_id,product_name,batch_number,production_date,distribution_area',
            'bs:id,name,username,parent_id',
            'agronomist:id,name,username',
            'images:id,complaint_id,image_path,ai_result',
            'logs:id,complaint_id,user_id,action,old_status,new_status,notes,created_datetime',
            'logs.user:id,name,username',
        ])->findOrFail($id);

        $this->authorizeComplaint($item, false);

        return inertia('admin/complaint/Detail', [
            'data' => $item,
        ]);
    }

    public function data(Request $request)
    {
        $orderBy = $request->get('order_by', 'id');
        $orderType = $request->get('order_type', 'desc');

        $q = $this->createQuery($request)
            ->with([
                'product:id,name',
                'batch:id,product_id,product_name,batch_number,production_date,distribution_area',
                'bs:id,name,username,parent_id',
                'agronomist:id,name,username',
                'images:id,complaint_id,image_path',
            ])
            ->orderBy($orderBy, $orderType);

        $items = $q->paginate($request->get('per_page', 10))->withQueryString();

        return response()->json($items);
    }

    public function analyticsData(Request $request)
    {
        $q = $this->createQuery($request);

        $all = (clone $q)->get([
            'id', 'category', 'severity', 'status', 'product_id', 'product_name', 'region', 'bs_id',
            'sla_hours', 'response_time_hours', 'resolution_time_hours', 'created_datetime', 'responded_datetime', 'resolved_datetime',
        ]);

        $now = now();
        $startOfDay = $now->copy()->startOfDay();
        $startOfMonth = $now->copy()->startOfMonth();
        $startOfYear = $now->copy()->startOfYear();

        $total = [
            'daily' => $all->where('created_datetime', '>=', $startOfDay)->count(),
            'monthly' => $all->where('created_datetime', '>=', $startOfMonth)->count(),
            'yearly' => $all->where('created_datetime', '>=', $startOfYear)->count(),
            'all' => $all->count(),
        ];

        $byCategory = $all->groupBy('category')->map(fn($items, $key) => [
            'category' => $key,
            'label' => Complaint::Categories[$key] ?? $key,
            'total' => $items->count(),
        ])->values()->sortByDesc('total')->values();

        $byProduct = $all->groupBy(function ($item) {
            return $item->product_id ?: ('name:' . ($item->product_name ?: '-'));
        })->map(function ($items) {
            $first = $items->first();
            return [
                'product_id' => $first->product_id,
                'product_name' => $first->product_name ?: '-',
                'total' => $items->count(),
                'high_severity' => $items->where('severity', Complaint::Severity_High)->count(),
            ];
        })->sortByDesc('total')->values();

        $byRegion = $all->groupBy(fn($item) => trim((string) ($item->region ?: '-')))->map(function ($items, $region) {
            return [
                'region' => $region,
                'total' => $items->count(),
                'high_severity' => $items->where('severity', Complaint::Severity_High)->count(),
            ];
        })->sortByDesc('total')->values();

        $byBs = $all->groupBy('bs_id')->map(function ($items, $bsId) {
            $first = $items->first();
            $total = $items->count();
            $resolved = $items->whereIn('status', [Complaint::Status_Resolved, Complaint::Status_Closed])->count();
            $valid = $items->where('is_valid', true)->count();
            $invalid = $items->where('is_valid', false)->count();
            $validRatio = $total > 0 ? ($valid / $total) : 0.5;
            $resolveRatio = $total > 0 ? ($resolved / $total) : 0;
            $penalty = min(20, $total * 0.4);
            $score = max(0, min(100, round((($validRatio * 55) + ($resolveRatio * 45)) * 100 - $penalty, 2)));

            return [
                'bs_id' => (int) $bsId,
                'bs_name' => $first?->bs?->name ?? ('BS#' . $bsId),
                'total' => $total,
                'resolved' => $resolved,
                'valid' => $valid,
                'invalid' => $invalid,
                'score' => $score,
            ];
        })->sortByDesc('total')->values();

        $trend = collect(range(0, 11))->map(function ($offset) use ($all, $now) {
            $month = $now->copy()->startOfMonth()->subMonths(11 - $offset);
            $next = $month->copy()->addMonth();
            $count = $all->filter(fn($item) => $item->created_datetime && Carbon::parse($item->created_datetime)->betweenIncluded($month, $next->copy()->subSecond()))->count();
            return [
                'month' => $month->format('Y-m'),
                'label' => $month->translatedFormat('M y'),
                'total' => $count,
            ];
        });

        $heatmap = $byRegion->map(function ($row) {
            $severityWeight = ($row['high_severity'] * 3) + (($row['total'] - $row['high_severity']) * 1);
            return [
                'region' => $row['region'],
                'total' => $row['total'],
                'severity_weight' => $severityWeight,
            ];
        })->values();

        $overdue = $all->filter(function ($item) use ($now) {
            if (in_array($item->status, [Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
                return false;
            }
            if (!$item->created_datetime) {
                return false;
            }
            $deadline = Carbon::parse($item->created_datetime)->addHours((int) ($item->sla_hours ?: 48));
            return $now->greaterThan($deadline);
        })->count();

        $avgResponse = round((float) $all->whereNotNull('response_time_hours')->avg('response_time_hours'), 2);
        $avgResolution = round((float) $all->whereNotNull('resolution_time_hours')->avg('resolution_time_hours'), 2);

        $productComplaintMap = $byProduct->keyBy(fn($x) => (int) ($x['product_id'] ?? 0));
        $salesByProduct = SaleItem::query()
            ->join('sales', 'sales.id', '=', 'sale_items.sale_id')
            ->where('sales.status', 'released')
            ->selectRaw('sale_items.product_id, COUNT(*) as trx_count, SUM(sale_items.quantity) as qty_sum, SUM(sale_items.subtotal) as amount_sum')
            ->groupBy('sale_items.product_id')
            ->get()
            ->map(function ($row) use ($productComplaintMap) {
                $complaints = (int) ($productComplaintMap[(int) $row->product_id]['total'] ?? 0);
                $qty = (float) ($row->qty_sum ?? 0);
                return [
                    'product_id' => (int) $row->product_id,
                    'trx_count' => (int) $row->trx_count,
                    'qty_sum' => $qty,
                    'amount_sum' => (float) ($row->amount_sum ?? 0),
                    'complaints' => $complaints,
                    'complaint_rate_per_1000_qty' => $qty > 0 ? round(($complaints / $qty) * 1000, 2) : 0,
                ];
            });

        $insights = $this->generateInsights($byProduct, $byRegion, $byCategory, $salesByProduct);

        return response()->json([
            'total' => $total,
            'by_category' => $byCategory,
            'by_product' => $byProduct,
            'by_region' => $byRegion,
            'by_bs' => $byBs,
            'trend' => $trend,
            'heatmap' => $heatmap,
            'sla' => [
                'avg_response_hours' => $avgResponse,
                'avg_resolution_hours' => $avgResolution,
                'overdue' => $overdue,
            ],
            'sales_integration' => $salesByProduct,
            'insights' => $insights,
        ]);
    }

    public function mapData(Request $request)
    {
        $rows = $this->createQuery($request)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->with(['product:id,name', 'bs:id,name'])
            ->limit(2000)
            ->get([
                'id', 'title', 'category', 'severity', 'status', 'latitude', 'longitude', 'region', 'product_id', 'bs_id', 'created_datetime'
            ]);

        return response()->json([
            'rows' => $rows,
            'total' => $rows->count(),
        ]);
    }

    public function save(Request $request, FonteWhatsAppService $waService)
    {
        $validated = $request->validate([
            'id' => 'nullable|integer|exists:complaints,id',
            'title' => 'required|string|max:255',
            'category' => 'required|in:rebah_semai,pertumbuhan_lambat,keseragaman_jelek,vigor_jelek,daya_tumbuh_rendah,bulai,busuk_batang,other',
            'description' => 'nullable|string|max:5000',
            'product_id' => 'nullable|integer|exists:products,id',
            'product_name' => 'nullable|string|max:255',
            'batch_id' => 'nullable|integer|exists:product_batches,id',
            'batch_number' => 'nullable|string|max:120',
            'production_date' => 'nullable|date',
            'distribution_area' => 'nullable|string|max:255',
            'bs_id' => 'nullable|integer|exists:users,id',
            'location' => 'nullable|string|max:255',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'region' => 'nullable|string|max:255',
            'severity' => 'required|in:low,medium,high',
            'status' => 'nullable|in:open,in_progress,resolved,closed',
            'reporter_name' => 'nullable|string|max:255',
            'is_valid' => 'nullable|boolean',
            'source' => 'nullable|in:online,offline_sync',
            'images' => 'nullable|array|max:5',
            'images.*' => 'image|max:5120',
        ]);

        $user = Auth::user();
        $isNew = empty($validated['id']);

        $item = $isNew
            ? new Complaint()
            : Complaint::with(['images', 'bs', 'agronomist'])->findOrFail((int) $validated['id']);

        $this->authorizeComplaint($item, true);

        DB::transaction(function () use (&$item, $validated, $user, $waService, $isNew) {
            $product = null;
            if (!empty($validated['product_id'])) {
                $product = Product::find((int) $validated['product_id']);
            }

            $bsId = (int) ($validated['bs_id'] ?? 0);
            if ($user->role === User::Role_BS) {
                $bsId = (int) $user->id;
            }
            if ($bsId <= 0) {
                abort(422, 'BS harus dipilih.');
            }

            $bsUser = User::findOrFail($bsId);
            $agronomistId = $bsUser->parent_id ?: null;

            $batchId = $this->resolveBatchId($validated, $product);
            $aiResult = $this->generateAiSuggestion(
                (string) ($validated['category'] ?? Complaint::Category_RebahSemai),
                (string) ($validated['description'] ?? ''),
                (string) ($validated['severity'] ?? Complaint::Severity_Medium)
            );

            $oldStatus = $item->status;
            $newStatus = $validated['status'] ?? ($isNew ? Complaint::Status_Open : $item->status);
            $createdAt = $item->created_datetime ? Carbon::parse($item->created_datetime) : now();

            $item->fill([
                'title' => $validated['title'],
                'reporter_name' => $validated['reporter_name'] ?? null,
                'category' => $validated['category'],
                'description' => $validated['description'] ?? null,
                'product_id' => $validated['product_id'] ?? null,
                'product_name' => $product?->name ?: ($validated['product_name'] ?? null),
                'batch_id' => $batchId,
                'bs_id' => $bsId,
                'agronomist_id' => $agronomistId,
                'location' => $validated['location'] ?? null,
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'region' => $validated['region'] ?? null,
                'severity' => $validated['severity'],
                'status' => $newStatus,
                'ai_result' => $aiResult,
                'sla_hours' => $this->calculateSlaHours($validated['severity']),
                'is_valid' => array_key_exists('is_valid', $validated) ? $validated['is_valid'] : null,
                'source' => $validated['source'] ?? 'online',
            ]);

            if (!$item->responded_datetime && in_array($newStatus, [Complaint::Status_InProgress, Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
                $responded = now();
                $item->responded_datetime = $responded;
                $item->response_time_hours = round($createdAt->floatDiffInHours($responded), 2);
            }

            if (!$item->resolved_datetime && in_array($newStatus, [Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
                $resolved = now();
                $item->resolved_datetime = $resolved;
                $item->resolution_time_hours = round($createdAt->floatDiffInHours($resolved), 2);
            }

            $item->save();

            if (!empty($validated['images']) && is_array($validated['images'])) {
                foreach ($validated['images'] as $imageFile) {
                    $imagePath = $this->storeCompressedComplaintImage($imageFile);
                    ComplaintImage::create([
                        'complaint_id' => $item->id,
                        'image_path' => $imagePath,
                        'ai_result' => $aiResult,
                    ]);
                }
            }

            $this->createLog($item->id, $oldStatus, $newStatus, $isNew ? 'create' : 'update', 'Pembaruan data keluhan');

            if ($isNew && $item->agronomist_id) {
                $agronomist = User::find($item->agronomist_id);
                if ($agronomist) {
                    $waService->sendComplaintNotificationToAgronomist($agronomist, $bsUser, $item);
                }
            }

            if ($isNew && $user->role === User::Role_BS) {
                $waService->sendComplaintReceivedToBs($bsUser, $item);
            }

            if ($item->severity === Complaint::Severity_High) {
                $waService->sendHighSeverityComplaintAlertToAdmins($item, $bsUser);
            }

            if (!$isNew && $oldStatus !== $newStatus) {
                $waService->sendComplaintStatusUpdatedToBs($bsUser, $item);
            }
        });

        return redirect()->route('admin.complaint.detail', ['id' => $item->id])
            ->with('success', "Keluhan #{$item->id} berhasil disimpan.");
    }

    public function respond(Request $request, $id, FonteWhatsAppService $waService)
    {
        $item = Complaint::with(['bs'])->findOrFail($id);
        $this->authorizeComplaintRespond($item);

        $validated = $request->validate([
            'status' => 'required|in:open,in_progress,resolved,closed',
            'notes' => 'nullable|string|max:1000',
            'is_valid' => 'nullable|boolean',
        ]);

        $oldStatus = $item->status;
        $newStatus = $validated['status'];

        $item->status = $newStatus;
        if (array_key_exists('is_valid', $validated)) {
            $item->is_valid = $validated['is_valid'];
        }

        $createdAt = $item->created_datetime ? Carbon::parse($item->created_datetime) : now();
        if (!$item->responded_datetime && in_array($newStatus, [Complaint::Status_InProgress, Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
            $responded = now();
            $item->responded_datetime = $responded;
            $item->response_time_hours = round($createdAt->floatDiffInHours($responded), 2);
        }

        if (!$item->resolved_datetime && in_array($newStatus, [Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
            $resolved = now();
            $item->resolved_datetime = $resolved;
            $item->resolution_time_hours = round($createdAt->floatDiffInHours($resolved), 2);
        }

        $item->save();

        $this->createLog((int) $item->id, $oldStatus, $newStatus, 'respond', $validated['notes'] ?? null);

        if ($item->bs) {
            $waService->sendComplaintStatusUpdatedToBs($item->bs, $item);
        }

        return response()->json([
            'message' => "Status keluhan #{$item->id} diperbarui.",
            'data' => $item,
        ]);
    }

    public function delete($id)
    {
        $item = Complaint::findOrFail($id);
        $this->authorizeComplaintDelete($item);

        $item->delete();

        return response()->json([
            'message' => "Keluhan #{$item->id} berhasil dihapus.",
        ]);
    }

    public function export(Request $request)
    {
        $items = $this->createQuery($request)
            ->with(['product:id,name', 'batch:id,batch_number', 'bs:id,name', 'agronomist:id,name'])
            ->orderByDesc('id')
            ->get();

        $filename = 'Complaint Intelligence - ' . now()->format('Ymd_His') . '.xlsx';

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        $headers = ['ID', 'Tanggal', 'Judul', 'Kategori', 'Severity', 'Status', 'Produk', 'Batch', 'BS', 'Agronomis', 'Region', 'Lokasi', 'Lat', 'Lng', 'SLA (jam)', 'Response (jam)', 'Resolution (jam)', 'AI Result'];
        foreach ($headers as $i => $h) {
            $sheet->setCellValueByColumnAndRow($i + 1, 1, $h);
        }

        $rowNum = 2;
        foreach ($items as $item) {
            $sheet->setCellValueByColumnAndRow(1, $rowNum, $item->id);
            $sheet->setCellValueByColumnAndRow(2, $rowNum, optional($item->created_datetime)->format('Y-m-d H:i:s'));
            $sheet->setCellValueByColumnAndRow(3, $rowNum, $item->title);
            $sheet->setCellValueByColumnAndRow(4, $rowNum, Complaint::Categories[$item->category] ?? $item->category);
            $sheet->setCellValueByColumnAndRow(5, $rowNum, Complaint::Severities[$item->severity] ?? $item->severity);
            $sheet->setCellValueByColumnAndRow(6, $rowNum, Complaint::Statuses[$item->status] ?? $item->status);
            $sheet->setCellValueByColumnAndRow(7, $rowNum, $item->product?->name ?: $item->product_name);
            $sheet->setCellValueByColumnAndRow(8, $rowNum, $item->batch?->batch_number ?: '-');
            $sheet->setCellValueByColumnAndRow(9, $rowNum, $item->bs?->name ?: '-');
            $sheet->setCellValueByColumnAndRow(10, $rowNum, $item->agronomist?->name ?: '-');
            $sheet->setCellValueByColumnAndRow(11, $rowNum, $item->region ?: '-');
            $sheet->setCellValueByColumnAndRow(12, $rowNum, $item->location ?: '-');
            $sheet->setCellValueByColumnAndRow(13, $rowNum, $item->latitude);
            $sheet->setCellValueByColumnAndRow(14, $rowNum, $item->longitude);
            $sheet->setCellValueByColumnAndRow(15, $rowNum, $item->sla_hours);
            $sheet->setCellValueByColumnAndRow(16, $rowNum, $item->response_time_hours);
            $sheet->setCellValueByColumnAndRow(17, $rowNum, $item->resolution_time_hours);
            $sheet->setCellValueByColumnAndRow(18, $rowNum, $item->ai_result ?: '-');
            $rowNum++;
        }

        $response = new StreamedResponse(function () use ($spreadsheet) {
            $writer = new Xlsx($spreadsheet);
            $writer->save('php://output');
        });

        $response->headers->set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        $response->headers->set('Content-Disposition', 'attachment; filename="' . $filename . '"');

        return $response;
    }

    private function createQuery(Request $request)
    {
        $filter = $request->get('filter', []);
        $q = Complaint::query();

        if (!empty($filter['search'])) {
            $search = '%' . $filter['search'] . '%';
            $q->where(function ($query) use ($search) {
                $query->where('title', 'like', $search)
                    ->orWhere('description', 'like', $search)
                    ->orWhere('reporter_name', 'like', $search)
                    ->orWhere('location', 'like', $search)
                    ->orWhere('region', 'like', $search)
                    ->orWhere('product_name', 'like', $search);
            });
        }

        if (!empty($filter['category']) && $filter['category'] !== 'all') {
            $q->where('category', $filter['category']);
        }
        if (!empty($filter['severity']) && $filter['severity'] !== 'all') {
            $q->where('severity', $filter['severity']);
        }
        if (!empty($filter['status']) && $filter['status'] !== 'all') {
            $q->where('status', $filter['status']);
        }
        if (!empty($filter['product_id']) && $filter['product_id'] !== 'all') {
            $q->where('product_id', (int) $filter['product_id']);
        }
        if (!empty($filter['bs_id']) && $filter['bs_id'] !== 'all') {
            $q->where('bs_id', (int) $filter['bs_id']);
        }
        if (!empty($filter['year']) && $filter['year'] !== 'all') {
            $q->whereYear('created_datetime', (int) $filter['year']);
        }
        if (!empty($filter['month']) && $filter['month'] !== 'all') {
            $q->whereMonth('created_datetime', (int) $filter['month']);
        }

        $currentUser = Auth::user();
        if ($currentUser->role === User::Role_BS) {
            $q->where('bs_id', $currentUser->id);
        } elseif ($currentUser->role === User::Role_Agronomist) {
            $q->where(function ($sub) use ($currentUser) {
                $sub->where('agronomist_id', $currentUser->id)
                    ->orWhereHas('bs', function ($q2) use ($currentUser) {
                        $q2->where('parent_id', $currentUser->id);
                    });
            });
        }

        return $q;
    }

    private function authorizeComplaint(Complaint $complaint, bool $forEdit): void
    {
        $user = Auth::user();

        if ($user->role === User::Role_Admin) {
            return;
        }

        if ($user->role === User::Role_Agronomist) {
            if (!$complaint->exists) {
                return;
            }

            $allowed = ((int) $complaint->agronomist_id === (int) $user->id)
                || ((int) ($complaint->bs?->parent_id ?? 0) === (int) $user->id);
            if (!$allowed) {
                abort(403, 'Akses keluhan ditolak.');
            }
            return;
        }

        if ($user->role === User::Role_BS) {
            if (!$complaint->exists) {
                return;
            }
            if ((int) $complaint->bs_id !== (int) $user->id) {
                abort(403, 'Akses keluhan ditolak.');
            }
            if ($forEdit && in_array($complaint->status, [Complaint::Status_Resolved, Complaint::Status_Closed], true)) {
                abort(403, 'Keluhan yang sudah selesai tidak bisa diubah oleh BS.');
            }
            return;
        }

        abort(403, 'Akses keluhan ditolak.');
    }

    private function authorizeComplaintRespond(Complaint $complaint): void
    {
        $user = Auth::user();
        if ($user->role === User::Role_Admin) {
            return;
        }

        if ($user->role === User::Role_Agronomist) {
            $allowed = ((int) $complaint->agronomist_id === (int) $user->id)
                || ((int) ($complaint->bs?->parent_id ?? 0) === (int) $user->id);
            if ($allowed) {
                return;
            }
        }

        abort(403, 'Hanya admin/agronomis yang dapat merespon keluhan.');
    }

    private function authorizeComplaintDelete(Complaint $complaint): void
    {
        $user = Auth::user();
        if ($user->role === User::Role_Admin) {
            return;
        }

        if ($user->role === User::Role_BS && (int) $complaint->bs_id === (int) $user->id && $complaint->status === Complaint::Status_Open) {
            return;
        }

        abort(403, 'Anda tidak memiliki akses menghapus keluhan ini.');
    }

    private function calculateSlaHours(string $severity): int
    {
        return match ($severity) {
            Complaint::Severity_High => 24,
            Complaint::Severity_Medium => 48,
            default => 72,
        };
    }

    private function resolveBatchId(array $validated, ?Product $product): ?int
    {
        if (!empty($validated['batch_id'])) {
            return (int) $validated['batch_id'];
        }

        $batchNumber = trim((string) ($validated['batch_number'] ?? ''));
        if ($batchNumber === '') {
            return null;
        }

        $productName = $product?->name ?: trim((string) ($validated['product_name'] ?? ''));
        if ($productName === '') {
            $productName = 'UNKNOWN';
        }

        $batch = ProductBatch::firstOrCreate(
            [
                'product_name' => $productName,
                'batch_number' => $batchNumber,
            ],
            [
                'product_id' => $product?->id,
                'production_date' => $validated['production_date'] ?? null,
                'distribution_area' => $validated['distribution_area'] ?? null,
            ]
        );

        if (!$batch->product_id && $product?->id) {
            $batch->product_id = $product->id;
            $batch->save();
        }

        return (int) $batch->id;
    }

    private function generateAiSuggestion(string $category, string $description, string $severity): string
    {
        $text = strtolower(trim($description));

        $issue = 'General crop issue';
        $action = 'Periksa kondisi lahan dan lakukan observasi lanjutan.';

        if (str_contains($text, 'yellow') || str_contains($text, 'kuning') || str_contains($text, 'chlorosis')) {
            $issue = 'Kemungkinan defisiensi nitrogen';
            $action = 'Rekomendasi: evaluasi unsur N dan aplikasikan pupuk nitrogen bertahap.';
        } elseif (str_contains($text, 'hole') || str_contains($text, 'lubang') || str_contains($text, 'ulat')) {
            $issue = 'Kemungkinan serangan hama pengunyah daun';
            $action = 'Rekomendasi: lakukan monitoring hama dan aplikasi pengendalian terpadu.';
        } elseif ($category === Complaint::Category_RebahSemai) {
            $issue = 'Masalah rebah semai';
            $action = 'Rekomendasi: cek drainase, kepadatan semai, dan potensi serangan patogen pada fase awal.';
        } elseif ($category === Complaint::Category_PertumbuhanLambat) {
            $issue = 'Pertumbuhan tanaman lambat';
            $action = 'Rekomendasi: evaluasi nutrisi, pH tanah, kelembapan, dan kondisi lingkungan pertumbuhan.';
        } elseif ($category === Complaint::Category_KeseragamanJelek) {
            $issue = 'Keseragaman tanaman kurang baik';
            $action = 'Rekomendasi: cek kualitas benih, kedalaman tanam, dan keseragaman distribusi air/pupuk.';
        } elseif ($category === Complaint::Category_VigorJelek) {
            $issue = 'Vigor tanaman rendah';
            $action = 'Rekomendasi: lakukan evaluasi kondisi akar, kecukupan hara, dan stres lingkungan.';
        } elseif ($category === Complaint::Category_DayaTumbuhRendah) {
            $issue = 'Daya tumbuh rendah';
            $action = 'Rekomendasi: periksa mutu benih, kondisi persemaian, dan tingkat kelembapan media.';
        } elseif ($category === Complaint::Category_Bulai) {
            $issue = 'Indikasi serangan bulai';
            $action = 'Rekomendasi: lakukan rouging tanaman terinfeksi, kendalikan vektor, dan evaluasi fungisida sistemik sesuai anjuran.';
        } elseif ($category === Complaint::Category_BusukBatang) {
            $issue = 'Indikasi busuk batang';
            $action = 'Rekomendasi: kurangi kelembapan berlebih, perbaiki drainase, sanitasi area, dan evaluasi pengendalian patogen batang.';
        }

        $priority = match ($severity) {
            Complaint::Severity_High => 'Prioritas tinggi: respon < 24 jam.',
            Complaint::Severity_Medium => 'Prioritas menengah: respon < 48 jam.',
            default => 'Prioritas rendah: monitoring berkala.',
        };

        return "Possible issue: {$issue}.\nRecommended action: {$action}\n{$priority}";
    }

    private function storeCompressedComplaintImage($imageFile): string
    {
        $filename = time() . '_' . uniqid() . '_' . preg_replace('/\s+/', '_', $imageFile->getClientOriginalName());
        $relativePath = 'uploads/complaints/' . $filename;
        $absolutePath = public_path($relativePath);

        if (!is_dir(dirname($absolutePath))) {
            mkdir(dirname($absolutePath), 0775, true);
        }

        $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
        $image = $manager->read($imageFile);

        $width = $image->width();
        $height = $image->height();
        $ratio = max($width / 1400, $height / 1400);

        if ($ratio > 1) {
            $newWidth = (int) round($width / $ratio);
            $newHeight = (int) round($height / $ratio);
            $image->resize($newWidth, $newHeight, function ($constraint) {
                $constraint->aspectRatio();
                $constraint->upsize();
            });
        }

        $image->save($absolutePath, 78);

        return $relativePath;
    }

    private function createLog(int $complaintId, ?string $oldStatus, ?string $newStatus, string $action, ?string $notes = null): void
    {
        ComplaintLog::create([
            'complaint_id' => $complaintId,
            'user_id' => Auth::id(),
            'action' => $action,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'notes' => $notes,
        ]);
    }

    private function generateInsights($byProduct, $byRegion, $byCategory, $salesByProduct): array
    {
        $out = [];

        $topProduct = $byProduct->first();
        $topRegion = $byRegion->first();
        $topCategory = $byCategory->first();

        if ($topProduct && $topProduct['total'] > 0) {
            $out[] = "Produk {$topProduct['product_name']} memiliki keluhan tertinggi ({$topProduct['total']} kasus).";
        }

        if ($topRegion && $topRegion['total'] > 0) {
            $out[] = "Wilayah {$topRegion['region']} menunjukkan pola keluhan berulang ({$topRegion['total']} kasus).";
        }

        if ($topCategory && $topCategory['total'] > 0) {
            $out[] = "Kategori {$topCategory['label']} mendominasi keluhan ({$topCategory['total']} kasus).";
        }

        $riskySales = collect($salesByProduct)->sortByDesc('complaint_rate_per_1000_qty')->first();
        if ($riskySales && $riskySales['complaint_rate_per_1000_qty'] > 0) {
            $out[] = "Produk dengan rasio keluhan tertinggi terhadap penjualan: ID {$riskySales['product_id']} ({$riskySales['complaint_rate_per_1000_qty']} per 1000 qty).";
        }

        return $out;
    }
}
