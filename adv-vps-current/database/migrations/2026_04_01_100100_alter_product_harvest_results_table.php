<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->string('farmer_name', 255)->nullable()->after('location');
            $table->decimal('land_area', 10, 2)->nullable()->after('location');
            $table->boolean('is_multiple_harvest')->default(false)->after('harvest_age_days');
            $table->decimal('total_pieces', 12, 2)->nullable()->after('harvest_quantity');
            $table->decimal('per_piece_quantity', 12, 4)->nullable()->after('harvest_quantity');
        });
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn(['farmer_name', 'land_area', 'is_multiple_harvest', 'total_pieces', 'per_piece_quantity']);
        });
    }
};
