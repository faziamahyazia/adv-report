<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->boolean('is_completed')->default(true)->after('is_multiple_harvest');
        });

        // Data multi panen biasanya bersifat bertahap, tandai default sebagai belum selesai.
        DB::table('product_harvest_results')
            ->where('is_multiple_harvest', 1)
            ->update(['is_completed' => 0]);
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn('is_completed');
        });
    }
};
