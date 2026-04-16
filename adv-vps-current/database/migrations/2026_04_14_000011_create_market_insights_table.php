<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('market_insights')) {
            return;
        }

        Schema::create('market_insights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bs_user_id')->constrained('users');
            $table->foreignId('province_id')->nullable()->constrained('provinces');
            $table->unsignedSmallInteger('fiscal_year');
            $table->unsignedTinyInteger('month')->nullable();

            $table->decimal('market_size_value', 16, 2)->default(0);
            $table->decimal('market_share_percent', 5, 2)->default(0);
            $table->decimal('potential_value', 16, 2)->nullable();
            $table->text('potential_notes')->nullable();

            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users');
            $table->foreignId('updated_by_uid')->nullable()->constrained('users');

            $table->index(['fiscal_year', 'month'], 'market_insights_period_idx');
            $table->index(['bs_user_id', 'province_id'], 'market_insights_bs_province_idx');
            $table->unique(['bs_user_id', 'province_id', 'fiscal_year', 'month'], 'market_insights_unique_period_region');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('market_insights');
    }
};
