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
            if (!Schema::hasColumn('market_insights', 'product_id')) {
                $table->foreignId('product_id')->nullable()->after('province_id')->constrained('products');
            }

            if (!Schema::hasColumn('market_insights', 'market_size_seed_kg')) {
                $table->decimal('market_size_seed_kg', 14, 2)->nullable()->after('month');
            }

            $table->dropUnique('market_insights_unique_period_region');
            $table->unique(
                ['bs_user_id', 'province_id', 'product_id', 'fiscal_year', 'month'],
                'market_insights_unique_period_region_product'
            );
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('market_insights')) {
            return;
        }

        Schema::table('market_insights', function (Blueprint $table) {
            $table->dropUnique('market_insights_unique_period_region_product');

            if (Schema::hasColumn('market_insights', 'product_id')) {
                $table->dropConstrainedForeignId('product_id');
            }

            if (Schema::hasColumn('market_insights', 'market_size_seed_kg')) {
                $table->dropColumn('market_size_seed_kg');
            }

            $table->unique(['bs_user_id', 'province_id', 'fiscal_year', 'month'], 'market_insights_unique_period_region');
        });
    }
};
