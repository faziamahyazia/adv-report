<?php
// Test apakah Model toArray() include relasi photos
require __DIR__ . '/../bootstrap/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';

use App\Models\ProductHarvestResult;

$item = ProductHarvestResult::with('photos')->first();

if ($item) {
    $arr = $item->toArray();
    echo "<h2>Testing toArray() with photos relation</h2>";
    echo "<h3>Item ID: {$item->id}</h3>";
    echo "photos property exists on object: " . (isset($item->photos) ? 'YES' : 'NO') . "<br>";
    echo "photos array key exists in toArray(): " . (isset($arr['photos']) ? 'YES' : 'NO') . "<br>";

    if (isset($arr['photos'])) {
        echo "photos array has " . count($arr['photos']) . " items<br>";
        echo "<h4>Photos data:</h4>";
        echo "<pre>" . json_encode($arr['photos'], JSON_PRETTY_PRINT) . "</pre>";
    } else {
        echo "ERROR: photos array NOT in toArray() result!<br>";
        echo "<h4>Available keys in toArray():</h4>";
        echo "<pre>" . implode(", ", array_keys($arr)) . "</pre>";
    }
} else {
    echo "No harvest found";
}
?>
