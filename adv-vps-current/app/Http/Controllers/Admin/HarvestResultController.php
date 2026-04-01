<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductHarvestResult;
use App\Models\User;
use Illuminate\Http\Request;
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
            'total_pieces' => 'nullable|numeric|min:0',
            'farmer_name' => 'nullable|string|max:255',
            'land_area' => 'nullable|numeric|min:0',
            'location' => 'nullable|string|max:255',
            'strengths' => 'nullable|string',
            'weaknesses' => 'nullable|string',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:10240',
        ]);

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
            'harvest_quantity' => $validated['harvest_quantity'],
            'harvest_unit' => $validated['harvest_unit'],
            'per_piece_quantity' => $validated['per_piece_quantity'] ?? null,
            'is_multiple_harvest' => $validated['is_multiple_harvest'] ?? false,
            'total_pieces' => $validated['total_pieces'] ?? null,
            'farmer_name' => $validated['farmer_name'] ?? null,
            'land_area' => $validated['land_area'] ?? null,
            'location' => $validated['location'] ?? null,
            'strengths' => $validated['strengths'] ?? null,
            'weaknesses' => $validated['weaknesses'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'photo_path' => $photoPath,
        ]);

        return response()->json(['message' => 'Data hasil panen berhasil disimpan.']);
    }
}
