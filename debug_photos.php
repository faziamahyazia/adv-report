<?php
// Script untuk debug harvest photos
require 'adv-vps-current/bootstrap/autoload.php';
$app = require 'adv-vps-current/bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle($request = \Illuminate\Http\Request::capture());

use App\Models\ProductHarvestResult;

echo "=== Debugging Harvest Photos ===\n\n";

$items = ProductHarvestResult::with('photos')->limit(5)->get();

foreach ($items as $item) {
    echo "ID: {$item->id}\n";
    echo "Farmer: {$item->farmer_name}\n";
    echo "photo_path (legacy): " . ($item->photo_path ?? 'NULL') . "\n";
    echo "Photos count: " . count($item->photos) . "\n";

    if ($item->photos->count() > 0) {
        foreach ($item->photos as $p) {
            echo "  - {$p->image_path}\n";
        }
    }
    echo "---\n\n";
}
?>
