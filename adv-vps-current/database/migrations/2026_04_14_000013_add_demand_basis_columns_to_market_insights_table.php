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
            if (!Schema::hasColumn('market_insights', 'planted_area_ha')) {
                $table->decimal('planted_area_ha', 14, 2)->nullable()->after('month');
            }

            if (!Schema::hasColumn('market_insights', 'seed_need_per_ha_kg')) {
                $table->decimal('seed_need_per_ha_kg', 14, 2)->nullable()->after('planted_area_ha');
            }

            if (!Schema::hasColumn('market_insights', 'season_count')) {
                $table->decimal('season_count', 8, 2)->nullable()->after('seed_need_per_ha_kg');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('market_insights')) {
            return;
        }

        Schema::table('market_insights', function (Blueprint $table) {
            if (Schema::hasColumn('market_insights', 'season_count')) {
                $table->dropColumn('season_count');
            }

            if (Schema::hasColumn('market_insights', 'seed_need_per_ha_kg')) {
                $table->dropColumn('seed_need_per_ha_kg');
            }

            if (Schema::hasColumn('market_insights', 'planted_area_ha')) {
                $table->dropColumn('planted_area_ha');
            }
        });
    }
};
