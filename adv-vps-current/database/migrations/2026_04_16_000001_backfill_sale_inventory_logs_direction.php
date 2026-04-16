<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(<<<'SQL'
UPDATE inventory_logs il
JOIN sales s ON s.id = il.reference_sale_id
JOIN sale_items si ON si.sale_id = s.id AND si.product_id = il.product_id
SET
    il.movement_quantity = CASE
        WHEN s.sale_type = 'retailer' AND il.customer_id = s.retailer_id THEN ABS(si.quantity)
        WHEN s.sale_type = 'retailer' AND il.customer_id = s.distributor_id THEN -ABS(si.quantity)
        WHEN s.sale_type = 'distributor' AND il.customer_id = s.distributor_id THEN ABS(si.quantity)
        ELSE il.movement_quantity
    END,
    il.notes = CASE
        WHEN s.sale_type = 'retailer' AND il.customer_id = s.retailer_id THEN CONCAT('[SALE_SYNC#', s.id, '] IN via sales')
        WHEN s.sale_type = 'retailer' AND il.customer_id = s.distributor_id THEN CONCAT('[DIST_STOCK_SYNC#', s.id, '] OUT via sales')
        WHEN s.sale_type = 'distributor' AND il.customer_id = s.distributor_id THEN CONCAT('[DIST_STOCK_SYNC#', s.id, '] IN via sales')
        ELSE il.notes
    END
WHERE il.reference_sale_id IS NOT NULL
  AND (
    (s.sale_type = 'retailer' AND il.customer_id IN (s.distributor_id, s.retailer_id))
    OR (s.sale_type = 'distributor' AND il.customer_id = s.distributor_id)
  );
SQL);
    }

    public function down(): void
    {
        // Data backfill only.
    }
};