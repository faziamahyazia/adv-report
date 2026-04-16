<?php
require __DIR__ . '/bootstrap/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(\Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Sale;
use Illuminate\Support\Facades\Auth;

// Simulate agronomist user
$distributorSales = Sale::where('sale_type', 'distributor')
    ->whereBetween('date', ['2024-01-01', '2024-12-31'])
    ->with('items.product')
    ->get();

echo "=== DEBUG DISTRIBUTOR SALES ===\n";
echo "Total rows: " . count($distributorSales) . "\n\n";

$grandTotal = 0;
foreach ($distributorSales as $sale) {
    $saleTotal = 0;
    foreach ($sale->items as $item) {
        $price = $item->price ?: ($item->product->price_1 ?: $item->product->price_2 ?: 0);
        $saleTotal += ($item->quantity * $price);
    }
    $grandTotal += $saleTotal;
}

echo "Total Distributor Sales Value: Rp " . number_format($grandTotal, 0) . "\n";

// BS sales
$bsSales = Sale::where('sale_type', 'retailer')
    ->whereBetween('date', ['2024-01-01', '2024-12-31'])
    ->with('items.product')
    ->get();

$bsTotal = 0;
foreach ($bsSales as $sale) {
    $saleTotal = 0;
    foreach ($sale->items as $item) {
        $price = $item->price ?: ($item->product->price_1 ?: $item->product->price_2 ?: 0);
        $saleTotal += ($item->quantity * $price);
    }
    $bsTotal += $saleTotal;
}

echo "Total BS Sales Value: Rp " . number_format($bsTotal, 0) . "\n";
echo "Expected Result: Rp " . number_format($grandTotal - $bsTotal, 0) . "\n";
?>
