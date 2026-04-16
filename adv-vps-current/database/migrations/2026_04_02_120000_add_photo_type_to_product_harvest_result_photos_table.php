<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_harvest_result_photos', function (Blueprint $table) {
            $table->string('photo_type', 30)->default('general')->after('image_path');
            $table->index(['product_harvest_result_id', 'photo_type', 'sort_order'], 'phr_photos_type_sort_idx');
        });

        DB::table('product_harvest_result_photos')
            ->whereNull('photo_type')
            ->update(['photo_type' => 'general']);
    }

    public function down(): void
    {
        Schema::table('product_harvest_result_photos', function (Blueprint $table) {
            $table->dropIndex('phr_photos_type_sort_idx');
            $table->dropColumn('photo_type');
        });
    }
};
