<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DemoPlot;
use App\Models\Product;
use App\Models\ProductHarvestResult;
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
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
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

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
            $filename = 'harvest_' . time() . '_' . uniqid() . '.jpg';
            $photoPath = 'uploads/' . $filename;

            $image = $manager->read($request->file('photo'));
            $image->scaleDown(1600, 1600);
            $image->toJpeg(82)->save(public_path($photoPath));
        }

        ProductHarvestResult::create([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $demoPlot?->product_id ?? $validated['product_id'],
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'harvest_unit' => 'kg',
            'per_piece_quantity' => null,
            'is_multiple_harvest' => $isMultipleHarvest,
            'harvest_cycles' => $isMultipleHarvest ? $cycles->all() : null,
            'total_pieces' => $demoPlot?->population,
            'farmer_name' => $demoPlot?->owner_name ?? ($validated['farmer_name'] ?? null),
            'land_area' => $validated['land_area'] ?? null,
            'altitude_mdpl' => $validated['altitude_mdpl'] ?? null,
            'location' => null,
            'strengths' => $validated['strengths'] ?? null,
            'weaknesses' => $validated['weaknesses'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'photo_path' => $photoPath,
            'created_datetime' => now(),
            'created_by_uid' => $request->user()->id,
        ]);

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

        $photoPath = $item->photo_path;
        if ($request->hasFile('photo')) {
            if ($photoPath && file_exists(public_path($photoPath))) {
                @unlink(public_path($photoPath));
            }

            $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
            $filename = 'harvest_' . time() . '_' . uniqid() . '.jpg';
            $photoPath = 'uploads/' . $filename;

            $image = $manager->read($request->file('photo'));
            $image->scaleDown(1600, 1600);
            $image->toJpeg(82)->save(public_path($photoPath));
        }

        $item->fill([
            'demo_plot_id' => $demoPlot?->id,
            'product_id' => $demoPlot?->product_id ?? $validated['product_id'],
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'harvest_unit' => 'kg',
            'is_multiple_harvest' => $isMultipleHarvest,
            'harvest_cycles' => $isMultipleHarvest ? $cycles->all() : null,
            'total_pieces' => $demoPlot?->population ?? $item->total_pieces,
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
}
