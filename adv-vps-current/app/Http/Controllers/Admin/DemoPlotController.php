<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DemoPlot;
use App\Models\DemoPlotVisit;
use App\Models\User;
use App\Models\Product;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Intervention\Image\ImageManager;
use Illuminate\Validation\ValidationException;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class DemoPlotController extends Controller
{
    use AuthorizesRequests;

    public function index()
    {
        $current_user = Auth::user();
        $q = User::query();
        if ($current_user->role == User::Role_BS) {
            $q->where('id', $current_user->id);
        } else if ($current_user->role == User::Role_Agronomist) {
            $q->where('parent_id', $current_user->id);
        }

        $users = $q->where('role', User::Role_BS)
            ->where('active', true)
            ->orderBy('name')
            ->get();

        return inertia('admin/demo-plot/Index', [
            'products' => Product::query()->orderBy('name')->get(),
            'users' => $users,
        ]);
    }

    public function detail($id = 0)
    {
        $data = DemoPlot::with([
            'user',
            'product',
            'created_by_user:id,username',
            'updated_by_user:id,username',
        ])->findOrFail($id);

        $latestVisitPhoto = DemoPlotVisit::query()
            ->where('demo_plot_id', $data->id)
            ->whereNotNull('image_path')
            ->orderByDesc('visit_date')
            ->orderByDesc('id')
            ->value('image_path');

        $data->setAttribute('latest_visit_image_path', $latestVisitPhoto);

        $this->authorize('view', $data);

        return inertia('admin/demo-plot/Detail', [
            'data' => $data,
        ]);
    }

    public function data(Request $request)
    {
        $items = $this->createQuery($request)
            ->orderBy('demo_plots.updated_datetime', 'desc')
            ->paginate($request->get('per_page', 10))
            ->withQueryString();

        return response()->json($items);
    }

    public function duplicate(Request $request, $id)
    {
        $user = Auth::user();
        $item = DemoPlot::findOrFail($id);
        $item->id = 0;
        $item->user_id = $user->role == User::Role_BS ? $user->id : $item->user->id;
        $item->image_path = null;

        $this->authorize('update', $item);

        return inertia('admin/demo-plot/Editor', [
            'data' => $item,
            'users' => User::where('active', true)
                ->where('role', User::Role_BS)
                ->orderBy('username', 'asc')->get(),
            'products' => Product::orderBy('name', 'asc')->get(),
        ]);
    }

    public function editor(Request $request, $id = 0)
    {
        $user = Auth::user();
        $item = $id ? DemoPlot::findOrFail($id) : new DemoPlot([
            'user_id' => $user->role == User::Role_BS ? $user->id : null,
            'plant_date' => Carbon::now(),
            'active' => true,
            'plant_status' => DemoPlot::PlantStatus_NotYetPlanted,
        ]);

        $this->authorize('update', $item);

        return inertia('admin/demo-plot/Editor', [
            'data' => $item,
            'users' => User::where('active', true)
                ->where('role', User::Role_BS)
                ->orderBy('username', 'asc')->get(),
            'products' => Product::orderBy('name', 'asc')->get(),
        ]);
    }

    public function save(Request $request)
    {
        $validated =  $request->validate([
            'user_id'          => 'required|exists:users,id',
            'product_id'       => 'required|exists:products,id',
            'plant_date'       => 'required|date',
            'owner_name'       => 'required|string|max:100',
            'owner_phone'      => 'nullable|string|max:30',
            'notes'            => 'nullable|string|max:500',
            'field_location'   => 'nullable|string|max:100',
            'population'       => 'nullable|numeric|gt:0',
            'jumlah_tanam'     => 'required|numeric|gt:0',
            'db_germinasi'     => 'required|numeric|gte:0|lte:100',
            'latlong'          => 'nullable|string|max:100',
            'image'            => 'nullable|image|max:5120',
            'image_path'       => 'nullable|string',
            'active'           => 'nullable|boolean',
        ]);

        $item = !$request->id
            ? new DemoPlot([
                'plant_status' => DemoPlot::PlantStatus_NotYetPlanted,
            ])
            : DemoPlot::findOrFail($request->post('id', 0));

        $this->authorize('update', $item);

        // Force current user id
        $current_user = Auth::user();
        if ($current_user->role == User::Role_BS) {
            $validated['user_id'] = $current_user->id;
        }

        // Handle image upload jika ada
        if ($request->hasFile('image')) {
            $validated['image_path'] = store_public_image_upload(
                $request->file('image'),
                'uploads',
                $item->image_path
            );
        } else if (empty($validated['image_path'])) {
            // Hapus file lama jika ada
            if ($item->image_path && file_exists(public_path($item->image_path))) {
                @unlink(public_path($item->image_path)); // pakai @ untuk suppress error jika file tidak ada
            }
        }

        $product = Product::query()->findOrFail((int) $validated['product_id']);
        $bijiPerPcs = (int) ($product->jumlah_biji_per_pcs ?? 0);
        if ($bijiPerPcs <= 0) {
            return back()
                ->withErrors(['product_id' => 'Varietas belum memiliki nilai Jumlah Biji per pcs di Master Data.'])
                ->withInput();
        }

        // Calculate population from jumlah_tanam and db_germinasi
        $jumlahTanam = (int) ($validated['jumlah_tanam'] ?? 0);
        $dbGerminasi = (float) ($validated['db_germinasi'] ?? 0);
        
        if ($jumlahTanam > 0 && $dbGerminasi > 0) {
            $totalSeeds = $jumlahTanam * $bijiPerPcs;
            $validated['population'] = (int) round($totalSeeds * ($dbGerminasi / 100));
        }

        $item->fill($validated);
        $item->save();

        return redirect(route('admin.demo-plot.detail', ['id' => $item->id]))
            ->with('success', "DemoPlot #$item->id telah disimpan.");
    }

    public function updateCoverPhoto(Request $request, $id)
    {
        $plot = DemoPlot::with(['user'])->findOrFail($id);
        $currentUser = Auth::user();

        $canManage = $currentUser->role === User::Role_Admin
            || ($currentUser->role === User::Role_BS && (int) $plot->user_id === (int) $currentUser->id)
            || ($currentUser->role === User::Role_Agronomist && (int) ($plot->user?->parent_id ?? 0) === (int) $currentUser->id);

        if (!$canManage) {
            abort(403, 'Anda tidak memiliki akses untuk mengubah foto depan demo plot ini.');
        }

        $validated = $request->validate([
            'source' => 'required|in:upload,visit,reset',
            'image' => 'nullable|image|max:5120',
            'visit_id' => 'nullable|integer|exists:demo_plot_visits,id',
        ]);

        $newPath = null;

        if ($validated['source'] === 'reset') {
            if ($plot->image_path && file_exists(public_path($plot->image_path))) {
                @unlink(public_path($plot->image_path));
            }
            $plot->image_path = null;
            $plot->save();

            return response()->json([
                'message' => 'Foto depan dikembalikan ke default foto kunjungan terakhir.',
            ]);
        }

        if ($validated['source'] === 'upload') {
            if (!$request->hasFile('image')) {
                throw ValidationException::withMessages([
                    'image' => 'Foto dari galeri wajib dipilih.',
                ]);
            }

            $newPath = store_public_image_upload($request->file('image'), 'uploads', $plot->image_path);
        } else {
            if (empty($validated['visit_id'])) {
                throw ValidationException::withMessages([
                    'visit_id' => 'Foto kunjungan wajib dipilih.',
                ]);
            }

            $visit = DemoPlotVisit::query()
                ->where('demo_plot_id', $plot->id)
                ->find((int) $validated['visit_id']);

            if (!$visit) {
                throw ValidationException::withMessages([
                    'visit_id' => 'Foto kunjungan yang dipilih tidak ditemukan pada demo plot ini.',
                ]);
            }

            if (!$visit->image_path) {
                throw ValidationException::withMessages([
                    'visit_id' => 'Foto kunjungan yang dipilih tidak tersedia.',
                ]);
            }

            $sourcePath = public_path(normalize_public_image_path($visit->image_path));
            if (!file_exists($sourcePath)) {
                throw ValidationException::withMessages([
                    'visit_id' => 'File foto kunjungan tidak ditemukan.',
                ]);
            }

            $directory = 'uploads';
            $absoluteDirectory = public_path($directory);
            if (!is_dir($absoluteDirectory)) {
                mkdir($absoluteDirectory, 0755, true);
            }

            $newFilename = time() . '_cover_' . basename((string) $visit->image_path);
            $newPath = $directory . '/' . preg_replace('/[^A-Za-z0-9._-]/', '_', $newFilename);
            copy($sourcePath, public_path($newPath));

            if ($plot->image_path && file_exists(public_path($plot->image_path))) {
                @unlink(public_path($plot->image_path));
            }
        }

        $plot->image_path = $newPath;
        $plot->save();

        return response()->json([
            'message' => 'Foto depan demo plot berhasil diperbarui.',
            'image_path' => $newPath,
        ]);
    }

    public function delete($id)
    {
        $item = DemoPlot::with(['visits:id,demo_plot_id,image_path'])->findOrFail($id);

        DB::transaction(function () use ($item) {
            foreach ($item->visits as $visit) {
                if ($visit->image_path && file_exists(public_path($visit->image_path))) {
                    @unlink(public_path($visit->image_path));
                }
            }

            if ($item->image_path && file_exists(public_path($item->image_path))) {
                @unlink(public_path($item->image_path));
            }

            $item->visits()->delete();
            $item->delete();
        });

        return response()->json([
            'message' => "Demo Plot #$item->id telah dihapus."
        ]);
    }

    /**
     * Mengekspor daftar interaksi ke dalam format PDF atau Excel.
     */
    public function export(Request $request)
    {
        $items = $this->createQuery($request)
            ->orderBy('users.name', 'asc')
            ->orderBy('products.name', 'asc')
            ->get();

        $title = 'Daftar Demo Plot';
        $filename = $title . ' - ' . env('APP_NAME') . Carbon::now()->format('dmY_His');

        if ($request->get('format') == 'html') {
            return view('export.demo-plot-list-pdf', compact('items', 'title'));
        }

        if ($request->get('format') == 'pdf') {
            $pdf = Pdf::loadView('export.demo-plot-list-pdf', compact('items', 'title'))
                ->setPaper('A4', 'landscape');
            return $pdf->download($filename . '.pdf');
        }

        if ($request->get('format') == 'pdf-with-photo') {
            // Increase memory limit untuk PDF dengan foto
            ini_set('memory_limit', '512M');
            set_time_limit(120);

            $maxPhotoRows = 120;
            $userFilter = (string) data_get($request->get('filter', []), 'user_id', 'all');
            if ($userFilter === 'all') {
                foreach ($items as $index => $item) {
                    $item->pdf_disable_image = $index >= $maxPhotoRows;
                }
            }
            
            //return view('export.demo-plot-list-w-photo-pdf', compact('items', 'title'));
            $pdf = Pdf::loadView('export.demo-plot-list-w-photo-pdf', compact('items', 'title'))
                ->setPaper('A4', 'portrait');
            return $pdf->download($filename . '.pdf');
        }

        if ($request->get('format') == 'excel') {

            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();

            // Tambahkan header
            $sheet->setCellValue('A1', 'No');
            $sheet->setCellValue('B1', 'BS');
            $sheet->setCellValue('C1', 'Varietas');
            $sheet->setCellValue('D1', 'Pemilik');
            $sheet->setCellValue('E1', 'No HP');
            $sheet->setCellValue('F1', 'Lokasi');
            $sheet->setCellValue('G1', 'Umur');
            $sheet->setCellValue('H1', 'Last Visit');
            $sheet->setCellValue('I1', 'Status Tanaman');
            $sheet->setCellValue('J1', 'Status Demplot');
            $sheet->setCellValue('K1', 'Catatan');

            // Tambahkan data ke Excel
            $row = 2;
            foreach ($items as $i => $item) {
                $sheet->setCellValue('A' . $row, $i + 1);
                $sheet->setCellValue('B' . $row, optional($item->user)->name);
                $sheet->setCellValue('C' . $row, $item->product->name);
                $sheet->setCellValue('D' . $row, $item->owner_name);
                $sheet->setCellValue('E' . $row, $item->owner_phone);
                $sheet->setCellValue('F' . $row, $item->field_location);
                $sheet->setCellValue('G' . $row, $item->plant_date && $item->active ? (int) \Carbon\Carbon::parse($item->plant_date)->diffInDays(\Carbon\Carbon::now()) : '');
                $sheet->setCellValue('H' . $row, $item->last_visit ? Carbon::parse($item->last_visit)->format('d-m-Y') : '');
                $sheet->setCellValue('I' . $row, DemoPlot::PlantStatuses[$item->plant_status]);
                $sheet->setCellValue('J' . $row, $item->activ ? 'Aktif' : 'Tidak Aktif');
                $sheet->setCellValue('K' . $row, $item->notes);
                $row++;
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

    protected function createQuery(Request $request)
    {
        $current_user = Auth::user();
        $filter = $request->get('filter', []);

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
            ->addSelect(DB::raw('COALESCE(demo_plots.image_path, latest_visits.image_path) as display_image_path'))
            ->with([
                'user:id,username,name',
                'product:id,name',
            ]);

        if ($current_user->role == User::Role_Agronomist) {
            $q->whereHas('user', function ($query) use ($current_user) {
                $query->where('parent_id', $current_user->id);
            });
        } else if ($current_user->role == User::Role_BS) {
            $q->where('demo_plots.user_id', $current_user->id);
        }

        if (!empty($filter['search'])) {
            $q->where(function ($q) use ($filter) {
                $q->where('demo_plots.owner_name', 'like', '%' . $filter['search'] . '%')
                    ->orWhere('demo_plots.owner_phone', 'like', '%' . $filter['search'] . '%')
                    ->orWhere('demo_plots.field_location', 'like', '%' . $filter['search'] . '%')
                    ->orWhere('demo_plots.notes', 'like', '%' . $filter['search'] . '%');
            });
        }

        if (!empty($filter['user_id']) && ($filter['user_id'] != 'all')) {
            $q->where('demo_plots.user_id', '=', $filter['user_id']);
        }

        if (!empty($filter['product_id']) && ($filter['product_id'] != 'all')) {
            $q->where('demo_plots.product_id', '=', $filter['product_id']);
        }

        if (!empty($filter['plant_status']) && ($filter['plant_status'] != 'all')) {
            $q->where('demo_plots.plant_status', '=', $filter['plant_status']);
        }

        if (!empty($filter['status']) && ($filter['status'] != 'all')) {
            $q->where('demo_plots.active', '=', $filter['status'] == 'active');
        }

        return $q;
    }
}
