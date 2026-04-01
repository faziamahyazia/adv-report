<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DemoPlot;
use App\Models\Product;
use App\Models\ProductHarvestResult;
use App\Models\ProductHarvestResultPhoto;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Intervention\Image\ImageManager;

class HarvestResultController extends Controller
{
    public function index()
    {
        $user = request()->user();

        $demoPlotsQuery = DemoPlot::query()
            ->with(['product:id,name'])
            ->where('active', true)
            ->orderByDesc('updated_datetime')
            ->orderByDesc('id');

        if ($user && $user->role === User::Role_BS) {
            $demoPlotsQuery->where('user_id', $user->id);
        }

        $demoPlots = $demoPlotsQuery->get([
            'id',
            'user_id',
            'product_id',
            'owner_name',
            'population',
            'plant_date',
        ])->map(function ($item) {
            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'product_name' => $item->product?->name,
                'owner_name' => $item->owner_name,
                'population' => $item->population,
                'plant_date' => optional($item->plant_date)->format('Y-m-d'),
            ];
        })->values();

        return inertia('admin/harvest-result/Index', [
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name', 'jumlah_biji_per_pcs']),
            'demoPlots' => $demoPlots,
        ]);
    }

    public function store(Request $request)
    {
        if ($request->user()->role !== User::Role_BS) {
            abort(403, 'Hanya BS yang dapat input data hasil panen.');
        }

        $validated = $request->validate([
            'demo_plot_id' => 'nullable|exists:demo_plots,id',
            'product_id' => 'required|exists:products,id',
            'harvest_date' => 'required|date',
            'harvest_age_days' => 'nullable|integer|min:1|max:999',
            'harvest_quantity' => 'required|numeric|min:0',
            'total_pieces' => 'nullable|numeric|min:0',
            'germination_percentage' => 'nullable|numeric|min:0|max:100',
            'is_multiple_harvest' => 'nullable|boolean',
            'harvest_cycles' => 'nullable|array',
            'harvest_cycles.*.label' => 'nullable|string|max:10',
            'harvest_cycles.*.date' => 'nullable|date',
            'harvest_cycles.*.quantity' => 'nullable|numeric|min:0',
            'farmer_name' => 'nullable|string|max:255',
            'land_area' => 'nullable|numeric|min:0',
            'altitude_mdpl' => 'nullable|integer|min:0|max:9000',
            'strengths' => 'nullable|string',
            'weaknesses' => 'nullable|string',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:10240',
            'photos' => 'nullable|array|max:10',
            'photos.*' => 'nullable|image|max:10240',
        ]);

        $isMultipleHarvest = (bool) ($validated['is_multiple_harvest'] ?? false);
        $cycles = collect($validated['harvest_cycles'] ?? [])
            ->map(function ($cycle, $index) {
                $quantity = isset($cycle['quantity']) ? (float) $cycle['quantity'] : null;

                return [
                    'label' => trim((string) ($cycle['label'] ?? ('K' . ($index + 1)))) ?: ('K' . ($index + 1)),
                    'date' => $cycle['date'] ?? null,
                    'quantity' => $quantity,
                ];
            })
            ->filter(fn ($cycle) => $cycle['quantity'] !== null && $cycle['quantity'] > 0)
            ->values();

        if ($isMultipleHarvest && $cycles->isEmpty()) {
            throw ValidationException::withMessages([
                'harvest_cycles' => 'Isi minimal satu data panen bertahap (K1/K2/dst).',
            ]);
        }

        $demoPlotId = $validated['demo_plot_id'] ?? null;
        $demoPlot = null;
        if ($demoPlotId) {
            $demoPlot = DemoPlot::query()->findOrFail($demoPlotId);

            if ($request->user()->role === User::Role_BS && (int) $demoPlot->user_id !== (int) $request->user()->id) {
                abort(403, 'Demo Plot tidak dapat diakses.');
            }
        }

        $harvestQuantity = (float) $validated['harvest_quantity'];

        if ($isMultipleHarvest && $cycles->isNotEmpty()) {
            $harvestQuantity = (float) $cycles->sum('quantity');
        }

        $totalPieces = array_key_exists('total_pieces', $validated)
            ? (float) $validated['total_pieces']
            : (float) ($demoPlot?->population ?? 0);

        if ($totalPieces <= 0 && $demoPlot?->population) {
            $totalPieces = (float) $demoPlot->population;
        }

        $perPieceQuantity = $totalPieces > 0 ? ($harvestQuantity / $totalPieces) : null;

        $uploadedPhotos = $this->collectUploadedPhotos($request);
        $photoPaths = $this->storeHarvestPhotos($uploadedPhotos);
        $primaryPhotoPath = $photoPaths[0] ?? null;

        $item = ProductHarvestResult::create([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $demoPlot?->product_id ?? $validated['product_id'],
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'harvest_unit' => 'kg',
            'per_piece_quantity' => $perPieceQuantity,
            'is_multiple_harvest' => $isMultipleHarvest,
            'harvest_cycles' => $isMultipleHarvest ? $cycles->all() : null,
            'total_pieces' => $totalPieces > 0 ? $totalPieces : null,
            'germination_percentage' => $validated['germination_percentage'] ?? null,
            'farmer_name' => $demoPlot?->owner_name ?? ($validated['farmer_name'] ?? null),
            'land_area' => $validated['land_area'] ?? null,
            'altitude_mdpl' => $validated['altitude_mdpl'] ?? null,
            'location' => null,
            'strengths' => $validated['strengths'] ?? null,
            'weaknesses' => $validated['weaknesses'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'photo_path' => $primaryPhotoPath,
            'created_datetime' => now(),
            'created_by_uid' => $request->user()->id,
        ]);

        if (!empty($photoPaths)) {
            $this->attachPhotoRecords($item, $photoPaths);
        }

        return response()->json(['message' => 'Data hasil panen berhasil disimpan.']);
    }

    public function update(Request $request, $id)
    {
        $item = ProductHarvestResult::findOrFail($id);
        $this->authorizeManage($request->user(), $item);

        $validated = $request->validate([
            'demo_plot_id' => 'nullable|exists:demo_plots,id',
            'product_id' => 'required|exists:products,id',
            'harvest_date' => 'required|date',
            'harvest_age_days' => 'nullable|integer|min:1|max:999',
            'harvest_quantity' => 'required|numeric|min:0',
            'total_pieces' => 'nullable|numeric|min:0',
            'germination_percentage' => 'nullable|numeric|min:0|max:100',
            'is_multiple_harvest' => 'nullable|boolean',
            'harvest_cycles' => 'nullable|array',
            'harvest_cycles.*.label' => 'nullable|string|max:10',
            'harvest_cycles.*.date' => 'nullable|date',
            'harvest_cycles.*.quantity' => 'nullable|numeric|min:0',
            'farmer_name' => 'nullable|string|max:255',
            'land_area' => 'nullable|numeric|min:0',
            'altitude_mdpl' => 'nullable|integer|min:0|max:9000',
            'strengths' => 'nullable|string',
            'weaknesses' => 'nullable|string',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:10240',
            'photos' => 'nullable|array|max:10',
            'photos.*' => 'nullable|image|max:10240',
        ]);

        $isMultipleHarvest = (bool) ($validated['is_multiple_harvest'] ?? $item->is_multiple_harvest);

        $rawCycles = array_key_exists('harvest_cycles', $validated)
            ? ($validated['harvest_cycles'] ?? [])
            : ($item->harvest_cycles ?? []);

        $cycles = collect($rawCycles)
            ->map(function ($cycle, $index) {
                $quantity = isset($cycle['quantity']) ? (float) $cycle['quantity'] : null;

                return [
                    'label' => trim((string) ($cycle['label'] ?? ('K' . ($index + 1)))) ?: ('K' . ($index + 1)),
                    'date' => $cycle['date'] ?? null,
                    'quantity' => $quantity,
                ];
            })
            ->filter(fn ($cycle) => $cycle['quantity'] !== null && $cycle['quantity'] > 0)
            ->values();

        if ($isMultipleHarvest && $cycles->isEmpty() && (float) ($validated['harvest_quantity'] ?? 0) <= 0) {
            throw ValidationException::withMessages([
                'harvest_cycles' => 'Isi minimal satu data panen bertahap (K1/K2/dst) atau jumlah panen total.',
            ]);
        }

        $demoPlotId = $validated['demo_plot_id'] ?? $item->demo_plot_id;
        $demoPlot = null;
        if ($demoPlotId) {
            $demoPlot = DemoPlot::query()->findOrFail($demoPlotId);

            if ($request->user()->role === User::Role_BS && (int) $demoPlot->user_id !== (int) $request->user()->id) {
                abort(403, 'Demo Plot tidak dapat diakses.');
            }
        }

        $harvestQuantity = (float) $validated['harvest_quantity'];
        if ($isMultipleHarvest && $cycles->isNotEmpty()) {
            $harvestQuantity = (float) $cycles->sum('quantity');
        }

        $totalPieces = array_key_exists('total_pieces', $validated)
            ? (float) $validated['total_pieces']
            : (float) ($demoPlot?->population ?? $item->total_pieces ?? 0);

        if ($totalPieces <= 0 && $demoPlot?->population) {
            $totalPieces = (float) $demoPlot->population;
        }

        $perPieceQuantity = $totalPieces > 0 ? ($harvestQuantity / $totalPieces) : null;

        $photoPath = $item->photo_path;
        $uploadedPhotos = $this->collectUploadedPhotos($request);
        $newPhotoPaths = $this->storeHarvestPhotos($uploadedPhotos);

        if (!empty($newPhotoPaths)) {
            $this->attachPhotoRecords($item, $newPhotoPaths);
        }

        if (!$photoPath) {
            $photoPath = $newPhotoPaths[0] ?? null;
        }

        if (!$photoPath) {
            $photoPath = optional($item->photos()->orderBy('sort_order')->first())->image_path;
        }

        $item->fill([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $demoPlot?->product_id ?? $validated['product_id'],
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'harvest_unit' => 'kg',
            'per_piece_quantity' => $perPieceQuantity,
            'is_multiple_harvest' => $isMultipleHarvest,
            'harvest_cycles' => $isMultipleHarvest ? $cycles->all() : null,
            'total_pieces' => $totalPieces > 0 ? $totalPieces : null,
            'germination_percentage' => $validated['germination_percentage'] ?? $item->germination_percentage,
            'farmer_name' => $demoPlot?->owner_name ?? ($validated['farmer_name'] ?? null),
            'land_area' => $validated['land_area'] ?? null,
            'altitude_mdpl' => $validated['altitude_mdpl'] ?? null,
            'strengths' => $validated['strengths'] ?? null,
            'weaknesses' => $validated['weaknesses'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'photo_path' => $photoPath,
            'updated_datetime' => now(),
            'updated_by_uid' => $request->user()->id,
        ]);

        $item->save();

        return response()->json([
            'message' => 'Data hasil panen berhasil diperbarui.',
            'item' => $item,
        ]);
    }

    public function delete(Request $request, $id)
    {
        $item = ProductHarvestResult::findOrFail($id);
        $this->authorizeManage($request->user(), $item);

        if ($item->photo_path && file_exists(public_path($item->photo_path))) {
            @unlink(public_path($item->photo_path));
        }

        foreach ($item->photos as $photo) {
            if ($photo->image_path && file_exists(public_path($photo->image_path))) {
                @unlink(public_path($photo->image_path));
            }
        }

        $item->delete();

        return response()->json(['message' => 'Data hasil panen berhasil dihapus.']);
    }

    private function authorizeManage(User $user, ProductHarvestResult $item): void
    {
        if (in_array($user->role, [User::Role_Admin, User::Role_Agronomist], true)) {
            return;
        }

        if ($user->role === User::Role_BS && (int) $item->created_by_uid === (int) $user->id) {
            return;
        }

        abort(403, 'Anda tidak memiliki akses untuk mengubah data panen ini.');
    }

    private function collectUploadedPhotos(Request $request): array
    {
        $files = [];

        if ($request->hasFile('photos')) {
            foreach ((array) $request->file('photos') as $file) {
                if ($file) {
                    $files[] = $file;
                }
            }
        }

        if ($request->hasFile('photo')) {
            $files[] = $request->file('photo');
        }

        return $files;
    }

    private function storeHarvestPhotos(array $files): array
    {
        if (empty($files)) {
            return [];
        }

        $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
        $paths = [];

        foreach ($files as $index => $file) {
            $filename = 'harvest_' . time() . '_' . $index . '_' . uniqid() . '.jpg';
            $path = 'uploads/' . $filename;

            $image = $manager->read($file);
            $image->scaleDown(1600, 1600);
            $image->toJpeg(82)->save(public_path($path));

            $paths[] = $path;
        }

        return $paths;
    }

    private function attachPhotoRecords(ProductHarvestResult $item, array $paths): void
    {
        if (empty($paths)) {
            return;
        }

        $startOrder = (int) ($item->photos()->max('sort_order') ?? -1) + 1;
        $rows = [];
        foreach ($paths as $offset => $path) {
            $rows[] = [
                'product_harvest_result_id' => $item->id,
                'image_path' => $path,
                'sort_order' => $startOrder + $offset,
            ];
        }

        ProductHarvestResultPhoto::insert($rows);
    }
}
