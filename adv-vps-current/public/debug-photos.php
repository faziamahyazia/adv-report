<?php
// Test harvest API response
$db_host = '127.0.0.1';
$db_user = 'advproject';
$db_pass = 'AdvDB#2026!am';
$db_name = 'shiftech_crm';

try {
    $pdo = new PDO(
        "mysql:host=$db_host;dbname=$db_name;charset=utf8mb4",
        $db_user,
        $db_pass
    );

    // Simulate what controller does - get first harvest with photos
    $stmt = $pdo->query("
    SELECT
        phr.id,
        phr.farmer_name,
        phr.product_id,
        phr.photo_path,
        phr.created_datetime,
        GROUP_CONCAT(CONCAT('{\"id\":',phrp.id,',\"image_path\":\"',phrp.image_path,'\"}') SEPARATOR ',') as photos_json
    FROM product_harvest_results phr
    LEFT JOIN product_harvest_result_photos phrp ON phr.id = phrp.product_harvest_result_id
    GROUP BY phr.id
    ORDER BY phr.id DESC
    LIMIT 1
    ");

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "<h2>Raw Data from DB:</h2>";
    echo "<pre>";
    print_r($row);
    echo "</pre>";

    echo "<h3>photo_path value: " . ($row['photo_path'] ?? 'NULL') . "</h3>";
    echo "<h3>photos_json value: " . ($row['photos_json'] ?? 'NULL') . "</h3>";

    // Now let's manually build what the controller would return
    $arr = $row;
    $rawPhotoPath = trim((string) ($arr['photo_path'] ?? ''));
    $photoUrls = [];

    // Parse photos_json
    if (!empty($arr['photos_json'])) {
        $photos = json_decode('[' . $arr['photos_json'] . ']', true);
        if (is_array($photos)) {
            foreach ($photos as $photo) {
                $imgPath = trim((string) ($photo['image_path'] ?? ''));
                if ($imgPath !== '') {
                    $normalized = str_replace('\\\\', '/', ltrim($imgPath, '/'));
                    if (str_starts_with($normalized, 'public/')) {
                        $normalized = substr($normalized, 7);
                    }
                    $photoUrls[] = '/' . ltrim($normalized, '/');
                }
            }
        }
    }

    // Add legacy photo_path if exists
    if ($rawPhotoPath !== '') {
        $normalizedPhotoPath = str_replace('\\\\', '/', ltrim($rawPhotoPath, '/'));
        if (str_starts_with($normalizedPhotoPath, 'public/')) {
            $normalizedPhotoPath = substr($normalizedPhotoPath, 7);
        }
        $legacyUrl = '/' . ltrim($normalizedPhotoPath, '/');
        if (!in_array($legacyUrl, $photoUrls, true)) {
            array_unshift($photoUrls, $legacyUrl);
        }
    }

    $arr['photo_urls'] = array_values(array_unique($photoUrls));
    $arr['photo_url'] = $arr['photo_urls'][0] ?? null;

    echo "<h2>Result (what API should return):</h2>";
    echo "<pre>";
    echo "photo_url: " . ($arr['photo_url'] ?? 'NULL') . "\n";
    echo "photo_urls: " . json_encode($arr['photo_urls']) . "\n";
    echo "</pre>";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
