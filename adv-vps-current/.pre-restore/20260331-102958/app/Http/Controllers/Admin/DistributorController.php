<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\DistributorStock;
use App\Models\Province;
use App\Models\Sale;
use Illuminate\Http\Request;

class DistributorController extends Controller
{
    public function index()
    {
        return inertia('admin/distributor/Index', [
            'provinces' => Province::orderBy('name')->get(['id', 'name']),
        ]);
    }

    public function data(Request $request)
    {
        $orderBy   = $request->get('order_by', 'name');
        $orderType = $request->get('order_type', 'asc');
        $page      = (int) $request->get('page', 1);
        $perPage   = (int) $request->get('per_page', 25);
        $filter    = $request->get('filter', []);

        $q = Customer::with(['province', 'district'])
            ->where('type', Customer::Type_Distributor)
            ->withCount(['sales as total_transactions'])
            ->withSum('sales as total_sales', 'total_amount');

        if (!empty($filter['search'])) {
            $q->where('name', 'like', '%' . $filter['search'] . '%');
        }
        if (!empty($filter['province_id'])) {
            $q->where('province_id', $filter['province_id']);
        }
        if (isset($filter['status']) && $filter['status'] !== '') {
            $q->where('active', (bool) $filter['status']);
        }

        $total = $q->count();
        $allowed = ['name', 'id'];
        if (!in_array($orderBy, $allowed)) $orderBy = 'name';
        $items = $q->orderBy($orderBy, $orderType === 'desc' ? 'desc' : 'asc')
            ->skip(($page - 1) * $perPage)->take($perPage)->get();

        return response()->json([
            'data'         => $items,
            'total'        => $total,
            'current_page' => $page,
            'per_page'     => $perPage,
        ]);
    }

    public function detail($id)
    {
        $distributor = Customer::with(['province', 'district', 'village', 'assigned_user'])
            ->where('type', Customer::Type_Distributor)
            ->findOrFail($id);

        $stocks = DistributorStock::with('product:id,name,uom_1')
            ->where('distributor_id', $id)
            ->get();

        $recentSales = Sale::with(['retailer:id,name', 'items.product:id,name,price_1,price_2'])
            ->where('distributor_id', $id)
            ->orderByDesc('date')
            ->orderByDesc('id')
            ->get();

        $recentSales->transform(function ($sale) {
            $computedTotal = (float) $sale->items->sum(function ($item) {
                $price = (float) ($item->price ?? 0);
                if ($price <= 0) {
                    $price = (float) (($item->product->price_1 ?? 0) ?: ($item->product->price_2 ?? 0));
                }
                return (float) ($item->quantity ?? 0) * $price;
            });

            if ($computedTotal > 0 || (float) ($sale->total_amount ?? 0) <= 0) {
                $sale->total_amount = round($computedTotal, 2);
            }

            return $sale;
        });

        $recentSales = $recentSales
            ->filter(fn($sale) => (float) ($sale->total_amount ?? 0) > 0)
            ->values();

        return inertia('admin/distributor/Detail', [
            'data'         => array_merge($distributor->toArray(), ['distributor_stock' => $stocks]),
            'recent_sales' => $recentSales,
        ]);
    }
}
