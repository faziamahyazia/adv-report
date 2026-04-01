<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('distributor_targets')) {
            return;
        }

        if (!Schema::hasColumn('distributor_targets', 'actual_qty')) {
            Schema::table('distributor_targets', function (Blueprint $table) {
                $table->decimal('actual_qty', 12, 2)->nullable()->after('target_qty');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('distributor_targets') && Schema::hasColumn('distributor_targets', 'actual_qty')) {
            Schema::table('distributor_targets', function (Blueprint $table) {
                $table->dropColumn('actual_qty');
            });
        }
    }
};
