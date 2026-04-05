<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DemoPlot;
use App\Models\Product;
use App\Models\ProductHarvestResult;
use App\Models\ProductHarvestResultPhoto;
use App\Models\Setting;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
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
            'products' => Product::query()
                ->with('category:id,name')
                ->where('active', true)
                ->orderBy('name')
                ->get(['id', 'name', 'category_id', 'jumlah_biji_per_pcs'])
                ->map(function ($product) {
                    return [
                        'id' => $product->id,
                        'name' => $product->name,
                        'category_id' => $product->category_id,
                        'category_name' => $product->category?->name,
                        'jumlah_biji_per_pcs' => $product->jumlah_biji_per_pcs,
                    ];
                })
                ->values(),
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
            'putren_quantity' => 'nullable|numeric|min:0',
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
            'weakness_photos' => 'nullable|array|max:10',
            'weakness_photos.*' => 'nullable|image|max:10240',
            'thumbnail_selection' => 'nullable|string|max:50',
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

        $resolvedProductId = (int) ($demoPlot?->product_id ?? $validated['product_id']);
        $isFreshCorn = $this->isFreshCornProduct($resolvedProductId);

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
        $putrenQuantity = $isFreshCorn ? (float) ($validated['putren_quantity'] ?? 0) : 0;
        $putrenQuantity = $putrenQuantity > 0 ? $putrenQuantity : null;
        $putrenPerPieceQuantity = ($putrenQuantity !== null && $totalPieces > 0)
            ? ($putrenQuantity / $totalPieces)
            : null;

        $estimatedPlantsForPutren = $this->estimateGrownPlants($resolvedProductId, $totalPieces, (float) ($validated['germination_percentage'] ?? 0));
        $putrenPerTreeQuantity = ($putrenQuantity !== null && $estimatedPlantsForPutren !== null && $estimatedPlantsForPutren > 0)
            ? ($putrenQuantity / $estimatedPlantsForPutren)
            : null;

        $uploadedPhotos = $this->collectUploadedPhotos($request);
        $photoPaths = $this->storeHarvestPhotos($uploadedPhotos);
        $uploadedWeaknessPhotos = $this->collectUploadedPhotosByField($request, 'weakness_photos');
        $weaknessPhotoPaths = $this->storeHarvestPhotos($uploadedWeaknessPhotos, 'weakness');
        $primaryPhotoPath = $this->resolveThumbnailPath($validated['thumbnail_selection'] ?? null, [], $photoPaths);

        $item = ProductHarvestResult::create([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $resolvedProductId,
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'putren_quantity' => $putrenQuantity,
            'harvest_unit' => 'kg',
            'per_piece_quantity' => $perPieceQuantity,
            'putren_per_piece_quantity' => $putrenPerPieceQuantity,
            'putren_per_tree_quantity' => $putrenPerTreeQuantity,
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
            $this->attachPhotoRecords($item, $photoPaths, 'general');
        }

        if (!empty($weaknessPhotoPaths)) {
            $this->attachPhotoRecords($item, $weaknessPhotoPaths, 'weakness');
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
            'putren_quantity' => 'nullable|numeric|min:0',
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
            'weakness_photos' => 'nullable|array|max:10',
            'weakness_photos.*' => 'nullable|image|max:10240',
            'thumbnail_selection' => 'nullable|string|max:50',
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

        $resolvedProductId = (int) ($demoPlot?->product_id ?? $validated['product_id']);
        $isFreshCorn = $this->isFreshCornProduct($resolvedProductId);

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
        $putrenQuantity = $isFreshCorn ? (float) ($validated['putren_quantity'] ?? ($item->putren_quantity ?? 0)) : 0;
        $putrenQuantity = $putrenQuantity > 0 ? $putrenQuantity : null;
        $putrenPerPieceQuantity = ($putrenQuantity !== null && $totalPieces > 0)
            ? ($putrenQuantity / $totalPieces)
            : null;

        $germinationForPutren = (float) ($validated['germination_percentage'] ?? $item->germination_percentage ?? 0);
        $estimatedPlantsForPutren = $this->estimateGrownPlants($resolvedProductId, $totalPieces, $germinationForPutren);
        $putrenPerTreeQuantity = ($putrenQuantity !== null && $estimatedPlantsForPutren !== null && $estimatedPlantsForPutren > 0)
            ? ($putrenQuantity / $estimatedPlantsForPutren)
            : null;

        $existingPhotos = $item->photos()
            ->where(function ($query) {
                $query->where('photo_type', 'general')->orWhereNull('photo_type');
            })
            ->orderBy('sort_order')
            ->get(['id', 'image_path'])
            ->map(function ($photo) {
            return [
                'id' => (int) $photo->id,
                'image_path' => $photo->image_path,
            ];
        })->all();

        $photoPath = $item->photo_path;
        $uploadedPhotos = $this->collectUploadedPhotos($request);
        $newPhotoPaths = $this->storeHarvestPhotos($uploadedPhotos);
        $uploadedWeaknessPhotos = $this->collectUploadedPhotosByField($request, 'weakness_photos');
        $newWeaknessPhotoPaths = $this->storeHarvestPhotos($uploadedWeaknessPhotos, 'weakness');

        if (!empty($newPhotoPaths)) {
            $this->attachPhotoRecords($item, $newPhotoPaths, 'general');
        }

        if (!empty($newWeaknessPhotoPaths)) {
            $this->attachPhotoRecords($item, $newWeaknessPhotoPaths, 'weakness');
        }

        $photoPath = $this->resolveThumbnailPath($validated['thumbnail_selection'] ?? null, $existingPhotos, $newPhotoPaths, $photoPath);

        $item->fill([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $resolvedProductId,
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'putren_quantity' => $putrenQuantity,
            'harvest_unit' => 'kg',
            'per_piece_quantity' => $perPieceQuantity,
            'putren_per_piece_quantity' => $putrenPerPieceQuantity,
            'putren_per_tree_quantity' => $putrenPerTreeQuantity,
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

    public function deletePhoto(Request $request, $id, $photoId)
    {
        $item = ProductHarvestResult::findOrFail($id);
        $this->authorizeManage($request->user(), $item);

        $photo = $item->photos()
            ->where('id', (int) $photoId)
            ->where(function ($query) {
                $query->where('photo_type', 'general')->orWhereNull('photo_type');
            })
            ->firstOrFail();
        $deletedPath = trim((string) $photo->image_path);

        $photo->delete();

        if ($deletedPath !== '' && file_exists(public_path($deletedPath))) {
            @unlink(public_path($deletedPath));
        }

        $remainingPhotos = $item->photos()
            ->where(function ($query) {
                $query->where('photo_type', 'general')->orWhereNull('photo_type');
            })
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'image_path', 'sort_order']);

        if (trim((string) $item->photo_path) === $deletedPath) {
            $item->photo_path = optional($remainingPhotos->first())->image_path;
        }

        foreach ($remainingPhotos as $index => $remaining) {
            if ((int) $remaining->sort_order !== $index) {
                $remaining->sort_order = $index;
                $remaining->save();
            }
        }

        $item->updated_datetime = now();
        $item->updated_by_uid = $request->user()->id;
        $item->save();

        return response()->json([
            'message' => 'Foto panen berhasil dihapus.',
            'photo_path' => $item->photo_path,
        ]);
    }

    public function deleteLegacyPhoto(Request $request, $id)
    {
        $item = ProductHarvestResult::findOrFail($id);
        $this->authorizeManage($request->user(), $item);

        $validated = $request->validate([
            'photo_path' => 'required|string|max:255',
        ]);

        $currentPhotoPath = $this->normalizeStoredPath($item->photo_path);
        $requestedPhotoPath = $this->normalizeStoredPath($validated['photo_path']);

        if ($currentPhotoPath === '' || $requestedPhotoPath !== $currentPhotoPath) {
            throw ValidationException::withMessages([
                'photo_path' => 'Foto legacy tidak ditemukan atau sudah berubah.',
            ]);
        }

        $item->photo_path = optional(
            $item->photos()
                ->where(function ($query) {
                    $query->where('photo_type', 'general')->orWhereNull('photo_type');
                })
                ->orderBy('sort_order')
                ->first()
        )->image_path;
        $item->updated_datetime = now();
        $item->updated_by_uid = $request->user()->id;
        $item->save();

        if (file_exists(public_path($currentPhotoPath))) {
            @unlink(public_path($currentPhotoPath));
        }

        return response()->json([
            'message' => 'Foto legacy berhasil dihapus.',
            'photo_path' => $item->photo_path,
        ]);
    }

    public function exportPdf(Request $request, $id)
    {
        $item = ProductHarvestResult::with([
            'product:id,name,jumlah_biji_per_pcs',
            'createdBy:id,name',
            'demoPlot:id,owner_name,population,product_id',
            'photos:id,product_harvest_result_id,image_path,sort_order,photo_type',
        ])->findOrFail($id);

        $this->authorizeView($request->user());

        $cycles = collect($item->harvest_cycles ?? [])
            ->map(function ($cycle, $index) {
                $quantity = (float) ($cycle['quantity'] ?? 0);
                return [
                    'label' => trim((string) ($cycle['label'] ?? ('K' . ($index + 1)))) ?: ('K' . ($index + 1)),
                    'date' => $cycle['date'] ?? null,
                    'quantity' => $quantity,
                ];
            })
            ->filter(fn ($cycle) => $cycle['quantity'] > 0)
            ->values();

        if ($cycles->isEmpty() && (float) $item->harvest_quantity > 0) {
            $cycles = collect([[
                'label' => 'K1',
                'date' => optional($item->harvest_date)->format('Y-m-d'),
                'quantity' => (float) $item->harvest_quantity,
            ]]);
        }

        $maxCycle = (float) ($cycles->max('quantity') ?? 0);
        $cycleChartRows = $cycles->map(function ($cycle) use ($maxCycle) {
            $percent = $maxCycle > 0 ? (int) round(($cycle['quantity'] / $maxCycle) * 100) : 0;
            return [
                'label' => $cycle['label'],
                'date' => $cycle['date'],
                'quantity' => $cycle['quantity'],
                'percent' => $percent,
            ];
        })->values();

        $peakCycle = $cycleChartRows->sortByDesc('quantity')->first();
        $cycleAverage = $cycleChartRows->count() > 0
            ? (float) ($cycleChartRows->sum('quantity') / $cycleChartRows->count())
            : null;
        $firstCycleQty = (float) ($cycleChartRows->first()['quantity'] ?? 0);
        $lastCycleQty = (float) ($cycleChartRows->last()['quantity'] ?? 0);
        $cycleTrend = null;
        if ($cycleChartRows->count() >= 2) {
            if ($lastCycleQty > $firstCycleQty) {
                $cycleTrend = 'Meningkat';
            } elseif ($lastCycleQty < $firstCycleQty) {
                $cycleTrend = 'Menurun';
            } else {
                $cycleTrend = 'Stabil';
            }
        }

        $seedsPerPiece = (float) ($item->product?->jumlah_biji_per_pcs ?? 0);
        $totalPieces = (float) ($item->total_pieces ?? 0);
        if ($totalPieces <= 0) {
            $totalPieces = (float) ($item->demoPlot?->population ?? 0);
        }
        $germination = (float) ($item->germination_percentage ?? 0);
        $estimatedPlants = ($totalPieces > 0 && $seedsPerPiece > 0 && $germination > 0)
            ? ($totalPieces * $seedsPerPiece * ($germination / 100))
            : null;

        $perPieceYield = $item->per_piece_quantity;
        if (($perPieceYield === null || (float) $perPieceYield <= 0) && $totalPieces > 0) {
            $perPieceYield = (float) $item->harvest_quantity / $totalPieces;
        }

        $perTreeYield = ($estimatedPlants && $estimatedPlants > 0)
            ? ((float) $item->harvest_quantity / $estimatedPlants)
            : null;

        $isFreshCorn = $this->isFreshCornProduct((int) $item->product_id);
        $putrenQuantity = $isFreshCorn ? (float) ($item->putren_quantity ?? 0) : 0;
        $putrenQuantity = $putrenQuantity > 0 ? $putrenQuantity : null;

        $putrenPerPieceYield = null;
        if ($putrenQuantity !== null) {
            $putrenPerPieceYield = $item->putren_per_piece_quantity;
            if (($putrenPerPieceYield === null || (float) $putrenPerPieceYield <= 0) && $totalPieces > 0) {
                $putrenPerPieceYield = (float) $putrenQuantity / $totalPieces;
            }
        }

        $putrenPerTreeYield = null;
        if ($putrenQuantity !== null) {
            $putrenPerTreeYield = $item->putren_per_tree_quantity;
            if (($putrenPerTreeYield === null || (float) $putrenPerTreeYield <= 0) && $estimatedPlants && $estimatedPlants > 0) {
                $putrenPerTreeYield = (float) $putrenQuantity / $estimatedPlants;
            }
        }

        $companyLogoPath = (string) (Setting::value('company_logo_path') ?? '');
        $companyName = (string) (Setting::value('company_name') ?? 'My Company');
        $harvestPhotoPaths = collect([$item->photo_path])
            ->merge(
                $item->photos
                    ->filter(fn ($photo) => in_array((string) ($photo->photo_type ?? 'general'), ['general', ''], true))
                    ->pluck('image_path')
            )
            ->map(fn ($path) => $this->normalizeStoredPath($path))
            ->filter(fn ($path) => $path !== '')
            ->unique()
            ->values();

        $harvestPhotoDataUris = $harvestPhotoPaths
            ->map(fn ($path) => $this->toImageDataUri($path))
            ->filter()
            ->values();

        $weaknessPhotoPaths = $item->photos
            ->filter(fn ($photo) => (string) ($photo->photo_type ?? '') === 'weakness')
            ->pluck('image_path')
            ->map(fn ($path) => $this->normalizeStoredPath($path))
            ->filter(fn ($path) => $path !== '')
            ->unique()
            ->values();

        $weaknessPhotoDataUris = $weaknessPhotoPaths
            ->map(fn ($path) => $this->toImageDataUri($path))
            ->filter()
            ->values();

        $pdf = Pdf::loadView('admin.harvest-result.report-pdf', [
            'item' => $item,
            'harvestPhotoDataUris' => $harvestPhotoDataUris,
            'weaknessPhotoDataUris' => $weaknessPhotoDataUris,
            'companyLogoDataUri' => $this->toImageDataUri($companyLogoPath),
            'companyName' => $companyName,
            'zoneLabel' => $this->getAltitudeZoneLabel($item->altitude_mdpl),
            'cycleChartRows' => $cycleChartRows,
            'peakCycle' => $peakCycle,
            'cycleAverage' => $cycleAverage,
            'cycleTrend' => $cycleTrend,
            'generatedAt' => Carbon::now()->format('d M Y H:i'),
            'estimatedPlants' => $estimatedPlants,
            'perPieceYield' => $perPieceYield,
            'perTreeYield' => $perTreeYield,
            'isFreshCorn' => $isFreshCorn,
            'putrenQuantity' => $putrenQuantity,
            'putrenPerPieceYield' => $putrenPerPieceYield,
            'putrenPerTreeYield' => $putrenPerTreeYield,
        ])->setPaper('a4');

        $safeName = Str::slug((string) ($item->farmer_name ?: 'hasil-panen'));
        return $pdf->download("laporan-hasil-panen-{$safeName}-{$item->id}.pdf");
    }

    private function authorizeView(User $user): void
    {
        if (in_array($user->role, [User::Role_Admin, User::Role_Agronomist, User::Role_BS], true)) {
            return;
        }

        abort(403, 'Anda tidak memiliki akses untuk melihat laporan panen ini.');
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
            $incomingPhotos = $request->file('photos');
            if ($incomingPhotos instanceof UploadedFile) {
                $files[] = $incomingPhotos;
            } elseif (is_array($incomingPhotos)) {
                foreach ($incomingPhotos as $file) {
                    if ($file instanceof UploadedFile) {
                        $files[] = $file;
                    }
                }
            }
        }

        if ($request->hasFile('photo')) {
            $singlePhoto = $request->file('photo');
            if ($singlePhoto instanceof UploadedFile) {
                $files[] = $singlePhoto;
            }
        }

        return $files;
    }

    private function collectUploadedPhotosByField(Request $request, string $fieldName): array
    {
        $files = [];

        if (!$request->hasFile($fieldName)) {
            return $files;
        }

        $incomingPhotos = $request->file($fieldName);
        if ($incomingPhotos instanceof UploadedFile) {
            $files[] = $incomingPhotos;
        } elseif (is_array($incomingPhotos)) {
            foreach ($incomingPhotos as $file) {
                if ($file instanceof UploadedFile) {
                    $files[] = $file;
                }
            }
        }

        return $files;
    }

    private function storeHarvestPhotos(array $files, string $prefix = 'harvest'): array
    {
        if (empty($files)) {
            return [];
        }

        $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
        $paths = [];

        foreach ($files as $index => $file) {
            $filename = $prefix . '_' . time() . '_' . $index . '_' . uniqid() . '.jpg';
            $path = 'uploads/' . $filename;

            $image = $manager->read($file);
            $image->scaleDown(1600, 1600);
            $image->toJpeg(82)->save(public_path($path));

            $paths[] = $path;
        }

        return $paths;
    }

    private function attachPhotoRecords(ProductHarvestResult $item, array $paths, string $photoType = 'general'): void
    {
        if (empty($paths)) {
            return;
        }

        $startOrder = (int) ($item->photos()->where('photo_type', $photoType)->max('sort_order') ?? -1) + 1;
        $rows = [];
        foreach ($paths as $offset => $path) {
            $rows[] = [
                'product_harvest_result_id' => $item->id,
                'image_path' => $path,
                'sort_order' => $startOrder + $offset,
                'photo_type' => $photoType,
            ];
        }

        ProductHarvestResultPhoto::insert($rows);
    }

    private function resolveThumbnailPath(?string $thumbnailSelection, array $existingPhotos, array $newPhotoPaths, ?string $fallbackPhotoPath = null): ?string
    {
        $selection = trim((string) $thumbnailSelection);

        if ($selection !== '') {
            if (str_starts_with($selection, 'existing:')) {
                $photoId = (int) substr($selection, 9);
                foreach ($existingPhotos as $photo) {
                    if ((int) ($photo['id'] ?? 0) === $photoId) {
                        $imagePath = trim((string) ($photo['image_path'] ?? ''));
                        if ($imagePath !== '') {
                            return $imagePath;
                        }
                    }
                }
            }

            if (str_starts_with($selection, 'new:')) {
                $photoIndex = (int) substr($selection, 4);
                if (array_key_exists($photoIndex, $newPhotoPaths)) {
                    return $newPhotoPaths[$photoIndex];
                }
            }

            foreach ($newPhotoPaths as $photoPath) {
                if (trim((string) $photoPath) === $selection) {
                    return $photoPath;
                }
            }

            foreach ($existingPhotos as $photo) {
                if (trim((string) ($photo['image_path'] ?? '')) === $selection) {
                    return $photo['image_path'];
                }
            }
        }

        $fallback = trim((string) $fallbackPhotoPath);
        if ($fallback !== '') {
            return $fallback;
        }

        foreach ($existingPhotos as $photo) {
            $imagePath = trim((string) ($photo['image_path'] ?? ''));
            if ($imagePath !== '') {
                return $imagePath;
            }
        }

        return $newPhotoPaths[0] ?? null;
    }

    private function normalizeStoredPath(?string $path): string
    {
        $value = trim((string) $path);
        if ($value === '') {
            return '';
        }

        $normalized = str_replace('\\', '/', ltrim($value, '/'));
        if (Str::startsWith($normalized, 'public/')) {
            $normalized = substr($normalized, 7);
        }

        return $normalized;
    }

    private function getAltitudeZoneLabel($altitude): string
    {
        if ($altitude === null || $altitude === '') {
            return '-';
        }

        $value = (int) $altitude;
        if ($value <= 400) {
            return 'Lowland (0-400 mdpl)';
        }
        if ($value <= 700) {
            return 'Middleland (401-700 mdpl)';
        }
        return 'Highland (>700 mdpl)';
    }

    private function toImageDataUri(?string $path): ?string
    {
        $normalized = $this->normalizeStoredPath($path);
        if ($normalized === '') {
            return null;
        }

        $fullPath = public_path($normalized);
        if (!file_exists($fullPath) || !is_readable($fullPath)) {
            return null;
        }

        $mime = @mime_content_type($fullPath);
        if (!is_string($mime) || !Str::startsWith($mime, 'image/')) {
            $mime = 'image/jpeg';
        }

        $binary = @file_get_contents($fullPath);
        if ($binary === false) {
            return null;
        }

        return 'data:' . $mime . ';base64,' . base64_encode($binary);
    }

    private function isFreshCornProduct(int $productId): bool
    {
        if ($productId <= 0) {
            return false;
        }

        $product = Product::query()
            ->with('category:id,name')
            ->where('id', $productId)
            ->first(['id', 'name', 'category_id']);

        if (!$product) {
            return false;
        }

        $categoryName = strtolower(trim((string) ($product->category?->name ?? '')));
        if ($categoryName !== '') {
            return str_contains($categoryName, 'fresh corn');
        }

        return str_contains(strtolower(trim((string) $product->name)), 'fresh corn');
    }

    private function estimateGrownPlants(int $productId, float $totalPieces, float $germination): ?float
    {
        if ($totalPieces <= 0 || $germination <= 0) {
            return null;
        }

        $seedsPerPiece = (float) (Product::query()->where('id', $productId)->value('jumlah_biji_per_pcs') ?? 0);
        if ($seedsPerPiece <= 0) {
            return null;
        }

        return $totalPieces * $seedsPerPiece * ($germination / 100);
    }
}
