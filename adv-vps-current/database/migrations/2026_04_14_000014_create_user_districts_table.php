<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('user_districts')) {
            return;
        }

        Schema::create('user_districts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('district_id')->constrained('districts')->cascadeOnDelete();
            $table->unique(['user_id', 'district_id'], 'user_districts_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_districts');
    }
};
