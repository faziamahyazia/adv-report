<?php
// Simulate API response dari ProductKnowledgeController::harvestData
require 'bootstrap/autoload.php';
$app = require 'bootstrap/app.php';

use App\Models\ProductHarvestResult;
use App\Models\User;

// Get fresh controller-like response
$items = ProductHarvestResult::with([
    'product:id,name,price_1,uom_1,price_2,uom_2',
    'createdBy:id,name',
    'demoPlot:id,owner_name,population,product_id',
    'photos:id,product_harvest_result_id,image_path,sort_order',
])->orderByDesc('created_datetime')->orderByDesc('id')
    ->limit(200)->get()
    ->map(function ($item) {
        $canManage = true; // fake for test

        $arr = $item->toArray();
        $rawPhotoPath = trim((string) ($arr['photo_path'] ?? ''));
        $photoUrls = [];

        foreach (($arr['photos'] ?? []) as $photo) {
            $imgPath = trim((string) ($photo['image_path'] ?? ''));
            if ($imgPath === '') {
                continue;
            }
            $normalized = str_replace('\\\\', '/', ltrim($imgPath, '/'));
            if (str_starts_with($normalized, 'public/')) {
                $normalized = substr($normalized, 7);
            }
            $photoUrls[] = '/' . ltrim($normalized, '/');
        }

        if ($rawPhotoPath !== '') {
            $normalizedPhotoPath = str_replace('\\\\', '/', ltrim($rawPhotoPath, '/'));
            if (str_starts_with($normalizedPhotoPath, 'public/')) {
                $normalizedPhotoPath = substr($normalizedPhotoPath, 7);
            }
            $legacyUrl = '/' . ltrim($normalizedPhotoPath, '/');
            if (!in_array($legacyUrl, $photoUrls, true)) {
                array_unshift($photoUrls, $legacyUrl);
            }
        } else {
            $legacyUrl = null;
        }

        $arr['photo_urls'] = array_values(array_unique($photoUrls));
        $arr['photo_url'] = $arr['photo_urls'][0] ?? $legacyUrl;
        $arr['can_edit'] = $canManage;
        $arr['can_delete'] = $canManage;

        return $arr;
    })->values();

echo "<h2>API Response Simulation - First 2 Items</h2>";
foreach (array_slice($items, 0, 2) as $item) {
    echo "<h3>Item ID: {$item['id']} - {$item['farmer_name']}</h3>";
    echo "photo_url: " . ($item['photo_url'] ?? 'NULL') . "<br>";
    echo "photo_urls count: " . count($item['photo_urls']) . "<br>";
    echo "photo_urls:<br>";
    echo "<pre>" . json_encode($item['photo_urls'], JSON_PRETTY_PRINT) . "</pre>";
}
?>
