<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('demo_plots', function (Blueprint $table) {
            $table->integer('jumlah_tanam')->nullable()->after('population')->comment('Jumlah tanam (pcs)');
            $table->decimal('db_germinasi', 5, 2)->nullable()->after('jumlah_tanam')->comment('DB/Germinasi (%)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('demo_plots', function (Blueprint $table) {
            $table->dropColumn(['jumlah_tanam', 'db_germinasi']);
        });
    }
};
