<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->decimal('putren_quantity', 12, 2)->nullable()->after('harvest_quantity');
            $table->decimal('putren_per_piece_quantity', 12, 4)->nullable()->after('per_piece_quantity');
            $table->decimal('putren_per_tree_quantity', 12, 4)->nullable()->after('putren_per_piece_quantity');
        });
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn(['putren_quantity', 'putren_per_piece_quantity', 'putren_per_tree_quantity']);
        });
    }
};
