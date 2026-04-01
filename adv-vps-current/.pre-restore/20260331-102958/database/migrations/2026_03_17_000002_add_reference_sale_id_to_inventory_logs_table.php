<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inventory_logs', function (Blueprint $table) {
            $table->unsignedBigInteger('reference_sale_id')->nullable()->after('base_quantity');
            $table->index('reference_sale_id', 'idx_inventory_logs_reference_sale_id');
        });
    }

    public function down(): void
    {
        Schema::table('inventory_logs', function (Blueprint $table) {
            $table->dropIndex('idx_inventory_logs_reference_sale_id');
            $table->dropColumn('reference_sale_id');
        });
    }
};
