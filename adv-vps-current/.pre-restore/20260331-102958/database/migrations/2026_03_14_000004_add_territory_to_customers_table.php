<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('customers', 'province_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->foreignId('province_id')->nullable()->constrained('provinces')->after('address');
            });
        }

        if (!Schema::hasColumn('customers', 'district_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->foreignId('district_id')->nullable()->constrained('districts')->after('province_id');
            });
        }

        if (!Schema::hasColumn('customers', 'village_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->foreignId('village_id')->nullable()->constrained('villages')->after('district_id');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('customers', 'province_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->dropConstrainedForeignId('province_id');
            });
        }

        if (Schema::hasColumn('customers', 'district_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->dropConstrainedForeignId('district_id');
            });
        }

        if (Schema::hasColumn('customers', 'village_id')) {
            Schema::table('customers', function (Blueprint $table) {
                $table->dropConstrainedForeignId('village_id');
            });
        }
    }
};
