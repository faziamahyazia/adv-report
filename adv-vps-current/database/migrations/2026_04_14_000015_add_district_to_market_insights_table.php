<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('market_insights')) {
            return;
        }

        Schema::table('market_insights', function (Blueprint $table) {
            if (!Schema::hasColumn('market_insights', 'district_id')) {
                $table->foreignId('district_id')->nullable()->after('province_id')->constrained('districts');
            }

            $table->dropUnique('market_insights_unique_period_region_product');
            $table->unique(
                ['bs_user_id', 'district_id', 'product_id', 'fiscal_year', 'month'],
                'market_insights_unique_period_district_product'
            );
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('market_insights')) {
            return;
        }

        Schema::table('market_insights', function (Blueprint $table) {
            $table->dropUnique('market_insights_unique_period_district_product');
            $table->unique(
                ['bs_user_id', 'province_id', 'product_id', 'fiscal_year', 'month'],
                'market_insights_unique_period_region_product'
            );

            if (Schema::hasColumn('market_insights', 'district_id')) {
                $table->dropConstrainedForeignId('district_id');
            }
        });
    }
};
