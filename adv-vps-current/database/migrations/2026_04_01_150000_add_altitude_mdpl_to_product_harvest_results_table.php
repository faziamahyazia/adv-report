<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->unsignedInteger('altitude_mdpl')->nullable()->after('land_area');
        });
    }

    public function down(): void
    {
        Schema::table('product_harvest_results', function (Blueprint $table) {
            $table->dropColumn('altitude_mdpl');
        });
    }
};
