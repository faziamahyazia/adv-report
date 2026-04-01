<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DemoPlot;
use App\Models\ProductHarvestResult;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\ProductPhoto;
use App\Models\User;
use Illuminate\Http\Request;
use Intervention\Image\ImageManager;

class ProductKnowledgeController extends Controller
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

        return inertia('admin/product-knowledge/Index', [
            'categories' => ProductCategory::orderBy('name')->get(['id', 'name']),
            'products' => Product::where('active', true)->orderBy('name')->get(['id', 'name', 'jumlah_biji_per_pcs', 'price_1', 'uom_1', 'price_2', 'uom_2']),
            'demoPlots' => $demoPlots,
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

    public function harvestData(Request $request)
    {
        $filter = $request->get('filter', []);
        $user = $request->user();

        $q = ProductHarvestResult::with([
            'product:id,name,price_1,uom_1,price_2,uom_2',
            'createdBy:id,name',
            'demoPlot:id,owner_name,population,product_id',
        ])->orderByDesc('created_datetime')->orderByDesc('id');

        if (!empty($filter['search'])) {
            $search = trim($filter['search']);
            $q->where(function ($inner) use ($search) {
                $inner->where('farmer_name', 'like', '%' . $search . '%')
                    ->orWhere('strengths', 'like', '%' . $search . '%')
                    ->orWhere('weaknesses', 'like', '%' . $search . '%')
                    ->orWhere('notes', 'like', '%' . $search . '%')
                    ->orWhereHas('product', function ($productQ) use ($search) {
                        $productQ->where('name', 'like', '%' . $search . '%');
                    })
                    ->orWhereHas('createdBy', function ($userQ) use ($search) {
                        $userQ->where('name', 'like', '%' . $search . '%');
                    });
            });
        }

        if (!empty($filter['product_id']) && $filter['product_id'] !== 'all') {
            $q->where('product_id', (int) $filter['product_id']);
        }

        if (!empty($filter['altitude_zone']) && $filter['altitude_zone'] !== 'all') {
            switch ($filter['altitude_zone']) {
                case 'lowland':
                    $q->whereNotNull('altitude_mdpl')->whereBetween('altitude_mdpl', [0, 400]);
                    break;
                case 'middleland':
                    $q->whereNotNull('altitude_mdpl')->whereBetween('altitude_mdpl', [401, 700]);
                    break;
                case 'highland':
                    $q->whereNotNull('altitude_mdpl')->where('altitude_mdpl', '>', 700);
                    break;
            }
        }

        $items = $q->limit(200)->get()->map(function ($item) use ($user) {
            $canManage = in_array($user->role, [User::Role_Admin, User::Role_Agronomist], true)
                || ($user->role === User::Role_BS && (int) $item->created_by_uid === (int) $user->id);

            $arr = $item->toArray();
            $arr['can_edit'] = $canManage;
            $arr['can_delete'] = $canManage;

            return $arr;
        })->values();

        return response()->json($items);
    }

    public function harvestStore(Request $request)
    {
        // Method ini sekarang di HarvestResultController - untuk backward compatibility jika masih diakses
        return response()->json(['message' => 'Method tidak tersedia di sini.'], 410);
    }

}
