<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\ProductPhoto;
use Illuminate\Http\Request;
use Intervention\Image\ImageManager;

class ProductKnowledgeController extends Controller
{
    public function index()
    {
        return inertia('admin/product-knowledge/Index', [
            'categories' => ProductCategory::orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function data(Request $request)
    {
        $filter = $request->get('filter', []);

        $q = Product::with(['category', 'photos' => fn($q) => $q->orderBy('sort_order')->limit(1)])
            ->withCount('photos')
            ->where('active', true);

        if (!empty($filter['search'])) {
            $q->where('name', 'like', '%' . $filter['search'] . '%');
        }
        if (!empty($filter['category_id']) && $filter['category_id'] !== 'all') {
            $q->where('category_id', $filter['category_id']);
        }

        $items = $q->orderBy('name')->get();
        return response()->json($items);
    }

    public function gallery($id)
    {
        $product = Product::with(['category', 'photos'])->findOrFail($id);
        return inertia('admin/product-knowledge/Gallery', [
            'product' => $product,
        ]);
    }

    public function photoEditor($id)
    {
        $product = Product::with(['category', 'photos'])->findOrFail($id);
        return inertia('admin/product-knowledge/PhotoEditor', [
            'product' => $product,
        ]);
    }

    public function photoSave(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $request->validate([
            'image'   => 'required|image|max:5120',
            'caption' => 'nullable|string|max:255',
        ]);

        $file      = $request->file('image');
        $filename  = 'pk_' . time() . '_' . $file->getClientOriginalName();
        $imagePath = 'uploads/' . $filename;

        // Resize to max 1024px on longest side
        $manager = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
        $image   = $manager->read($file);
        $width   = $image->width();
        $height  = $image->height();
        $ratio   = max($width / 1024, $height / 1024);
        if ($ratio > 1) {
            $newWidth  = (int) round($width / $ratio);
            $newHeight = (int) round($height / $ratio);
            $image->resize($newWidth, $newHeight, function ($constraint) {
                $constraint->aspectRatio();
                $constraint->upsize();
            });
        }
        $image->save(public_path($imagePath));

        $nextSort = (ProductPhoto::where('product_id', $id)->max('sort_order') ?? 0) + 1;

        ProductPhoto::create([
            'product_id' => $product->id,
            'image_path' => $imagePath,
            'caption'    => $request->input('caption'),
            'sort_order' => $nextSort,
        ]);

        return back()->with('success', 'Foto berhasil diunggah.');
    }

    public function photoDelete($photoId)
    {
        $photo = ProductPhoto::findOrFail($photoId);

        if ($photo->image_path && file_exists(public_path($photo->image_path))) {
            @unlink(public_path($photo->image_path));
        }
        $photo->delete();

        return response()->json(['message' => 'Foto telah dihapus.']);
    }
}
