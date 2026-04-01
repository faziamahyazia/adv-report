<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
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
        return inertia('admin/harvest-result/Index', [
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function store(Request $request)
    {
        if ($request->user()->role !== User::Role_BS) {
            abort(403, 'Hanya BS yang dapat input data hasil panen.');
        }

        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'harvest_date' => 'required|date',
            'harvest_age_days' => 'nullable|integer|min:1|max:999',
            'harvest_quantity' => 'required|numeric|min:0',
            'harvest_unit' => 'required|string|in:kg,pcs',
            'per_piece_quantity' => 'nullable|numeric|min:0',
            'is_multiple_harvest' => 'nullable|boolean',
            'harvest_cycles' => 'nullable|array',
            'harvest_cycles.*.label' => 'nullable|string|max:10',
            'harvest_cycles.*.date' => 'nullable|date',
            'harvest_cycles.*.quantity' => 'nullable|numeric|min:0',
            'harvest_cycles.*.pieces' => 'nullable|numeric|min:0',
            'total_pieces' => 'nullable|numeric|min:0',
            'farmer_name' => 'nullable|string|max:255',
            'land_area' => 'nullable|numeric|min:0',
            'location' => 'nullable|string|max:255',
            'strengths' => 'nullable|string',
            'weaknesses' => 'nullable|string',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:10240',
        ]);

        $isMultipleHarvest = (bool) ($validated['is_multiple_harvest'] ?? false);
        $cycles = collect($validated['harvest_cycles'] ?? [])
            ->map(function ($cycle, $index) {
                $quantity = isset($cycle['quantity']) ? (float) $cycle['quantity'] : null;
                $pieces = isset($cycle['pieces']) ? (float) $cycle['pieces'] : null;

                return [
                    'label' => trim((string) ($cycle['label'] ?? ('K' . ($index + 1)))) ?: ('K' . ($index + 1)),
                    'date' => $cycle['date'] ?? null,
                    'quantity' => $quantity,
                    'pieces' => $pieces,
                ];
            })
            ->filter(fn ($cycle) => $cycle['quantity'] !== null && $cycle['quantity'] > 0)
            ->values();

        if ($isMultipleHarvest && $cycles->isEmpty()) {
            throw ValidationException::withMessages([
                'harvest_cycles' => 'Isi minimal satu data panen bertahap (K1/K2/dst).',
            ]);
        }

        $harvestQuantity = (float) $validated['harvest_quantity'];
        $totalPieces = isset($validated['total_pieces']) ? (float) $validated['total_pieces'] : null;

        if ($isMultipleHarvest && $cycles->isNotEmpty()) {
            $harvestQuantity = (float) $cycles->sum('quantity');
            $sumPieces = (float) $cycles->sum(fn ($cycle) => (float) ($cycle['pieces'] ?? 0));
            if ($sumPieces > 0) {
                $totalPieces = $sumPieces;
            }
        }

        $perPieceQuantity = isset($validated['per_piece_quantity']) ? (float) $validated['per_piece_quantity'] : null;
        if ($perPieceQuantity === null && $totalPieces && $totalPieces > 0 && $harvestQuantity > 0) {
            $perPieceQuantity = $harvestQuantity / $totalPieces;
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
            'product_id' => $validated['product_id'],
            'harvest_date' => $validated['harvest_date'],
            'harvest_age_days' => $validated['harvest_age_days'] ?? null,
            'harvest_quantity' => $harvestQuantity,
            'harvest_unit' => $validated['harvest_unit'],
            'per_piece_quantity' => $perPieceQuantity,
            'is_multiple_harvest' => $isMultipleHarvest,
            'harvest_cycles' => $isMultipleHarvest ? $cycles->all() : null,
            'total_pieces' => $totalPieces,
            'farmer_name' => $validated['farmer_name'] ?? null,
            'land_area' => $validated['land_area'] ?? null,
            'location' => $validated['location'] ?? null,
            'strengths' => $validated['strengths'] ?? null,
            'weaknesses' => $validated['weaknesses'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'photo_path' => $photoPath,
            'created_datetime' => now(),
            'created_by_uid' => $request->user()->id,
        ]);

        return response()->json(['message' => 'Data hasil panen berhasil disimpan.']);
    }
}
