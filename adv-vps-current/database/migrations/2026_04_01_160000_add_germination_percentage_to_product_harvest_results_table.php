<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->decimal('germination_percentage', 5, 2)
                ->nullable()
                ->after('total_pieces');
        });
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn('germination_percentage');
        });
    }
};