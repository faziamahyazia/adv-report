<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::getConnection()->getDriverName() === 'mysql') {
            DB::statement("ALTER TABLE complaints MODIFY category VARCHAR(80) NOT NULL DEFAULT 'other'");
        }
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() === 'mysql') {
            DB::statement("ALTER TABLE complaints MODIFY category ENUM('germination','growth','pest_disease','other') NOT NULL DEFAULT 'other'");
        }
    }
};
