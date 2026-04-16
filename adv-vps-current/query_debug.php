<?php
define('LARAVEL_START', microtime(true));
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== INVENTORY LOGS (last 10) ===\n";
$logs = DB::table('inventory_logs')
    ->select('id', 'customer_id', 'product_id', 'quantity', 'notes', 'retailer_type', 'reference_sale_id')
    ->orderByDesc('id')
    ->limit(10)
    ->get();

foreach ($logs as $log) {
    echo "ID:{$log->id} | CustID:{$log->customer_id} | Qty:{$log->quantity} | RType:{$log->retailer_type} | Ref Sale:{$log->reference_sale_id}\n";
    echo "  Notes: {$log->notes}\n";
}

echo "\n=== PRODUCTS (Lavanta) ===\n";
$products = DB::table('products')->where('name', 'like', '%Lavanta%')->get(['id', 'name']);
foreach ($products as $p) {
    echo "ID:{$p->id} | Name:{$p->name}\n";
}

echo "\n=== DISTRIBUTOR STOCK (all) ===\n";
$stocks = DB::table('distributor_stock')
    ->select('distributor_stock.id', 'distributor_stock.distributor_id', 'distributor_stock.product_id', 'distributor_stock.stock_quantity', 'products.name as product_name', 'customers.name as distributor_name')
    ->join('products', 'distributor_stock.product_id', '=', 'products.id')
    ->join('customers', 'distributor_stock.distributor_id', '=', 'customers.id')
    ->orderBy('distributor_stock.id', 'desc')
    ->limit(15)
    ->get();
foreach ($stocks as $s) {
    echo "ID:{$s->id} | Distributor:{$s->distributor_name}(#{$s->distributor_id}) | Product:{$s->product_name} | Stock:{$s->stock_quantity}\n";
}
