<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->json('harvest_cycles')->nullable()->after('is_multiple_harvest');
        });
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn('harvest_cycles');
        });
    }
};
