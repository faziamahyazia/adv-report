<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            // Sumber barang: 'distributor' (langsung dari distributor) atau 'r1' (dari R1, untuk penjualan ke R2)
            // NULL berarti tidak relevan (penjualan ke distributor itu sendiri)
            $table->string('source_from', 20)->nullable()->default('distributor')->after('retailer_id');
        });

        // Data lama yang sale_type = 'retailer' set ke 'distributor' (default)
        DB::table('sales')
            ->where('sale_type', 'retailer')
            ->whereNull('source_from')
            ->update(['source_from' => 'distributor']);
    }

    public function down(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            $table->dropColumn('source_from');
        });
    }
};
