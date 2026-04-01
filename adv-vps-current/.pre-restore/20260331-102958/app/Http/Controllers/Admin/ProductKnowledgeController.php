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
            'images'          => 'required|array|min:1|max:10',
            'images.*'        => 'required|image|max:10240',
            'captions.*'      => 'nullable|string|max:255',
            'thumbnail_index' => 'nullable|integer|min:0',
        ]);

        $files          = $request->file('images');
        $captions       = $request->input('captions', []);
        $thumbnailIndex = (int) $request->input('thumbnail_index', 0);

        // Re-number existing photos from 1 (0 is reserved for thumbnail).
        // This prevents sort_order from going negative on repeated uploads.
        $existing = ProductPhoto::where('product_id', $id)->orderBy('sort_order')->get();
        foreach ($existing as $idx => $p) {
            $p->sort_order = $idx + 1;
            $p->save();
        }
        $existingCount = $existing->count();

        $manager     = new ImageManager(new \Intervention\Image\Drivers\Gd\Driver());
        $newSortBase = $existingCount + 1;

        foreach ($files as $i => $file) {
            $filename  = 'pk_' . time() . '_' . $i . '_' . uniqid() . '.jpg';
            $imagePath = 'uploads/' . $filename;

            $image = $manager->read($file);
            $image->scaleDown(1024, 1024);
            $image->toJpeg(78)->save(public_path($imagePath));

            // Thumbnail gets sort_order 0 (lowest = first), others append after existing.
            $sortOrder = ($i == $thumbnailIndex) ? 0 : $newSortBase++;

            ProductPhoto::create([
                'product_id' => $product->id,
                'image_path' => $imagePath,
                'caption'    => $captions[$i] ?? null,
                'sort_order' => $sortOrder,
            ]);
        }

        return response()->json(['message' => 'Berhasil mengunggah ' . count($files) . ' foto.']);
    }

    public function setThumbnail($id, $photoId)
    {
        $photo = ProductPhoto::where('id', $photoId)->where('product_id', $id)->firstOrFail();

        // Set target to sort_order 0; re-number all others from 1.
        $others = ProductPhoto::where('product_id', $id)
            ->where('id', '!=', $photoId)
            ->orderBy('sort_order')
            ->get();

        $photo->sort_order = 0;
        $photo->save();

        foreach ($others as $idx => $p) {
            $p->sort_order = $idx + 1;
            $p->save();
        }

        return response()->json(['message' => 'Thumbnail berhasil diubah.']);
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
