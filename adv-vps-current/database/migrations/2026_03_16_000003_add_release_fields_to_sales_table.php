<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $hasStatus = Schema::hasColumn('sales', 'status');

        Schema::table('sales', function (Blueprint $table) {
            if (!Schema::hasColumn('sales', 'status')) {
                $table->string('status', 20)->default('pending')->after('sale_type');
            }
            if (!Schema::hasColumn('sales', 'released_datetime')) {
                $table->datetime('released_datetime')->nullable()->after('updated_datetime');
            }
            if (!Schema::hasColumn('sales', 'released_by_uid')) {
                $table->foreignId('released_by_uid')->nullable()->after('released_datetime')->constrained('users');
            }
        });

        if (!$hasStatus) {
            DB::table('sales')->update([
                'status' => 'released',
                'released_datetime' => now(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            if (Schema::hasColumn('sales', 'released_by_uid')) {
                $table->dropConstrainedForeignId('released_by_uid');
            }
            if (Schema::hasColumn('sales', 'released_datetime')) {
                $table->dropColumn('released_datetime');
            }
            if (Schema::hasColumn('sales', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};
