<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_harvest_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->cascadeOnDelete();
            $table->date('harvest_date');
            $table->unsignedSmallInteger('harvest_age_days')->nullable();
            $table->decimal('harvest_quantity', 12, 2)->nullable();
            $table->string('harvest_unit', 30)->default('kg/ha');
            $table->string('location', 255)->nullable();
            $table->text('strengths')->nullable();
            $table->text('weaknesses')->nullable();
            $table->text('notes')->nullable();
            $table->string('photo_path', 500)->nullable();

            $table->datetime('created_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users')->nullOnDelete();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('updated_by_uid')->nullable()->constrained('users')->nullOnDelete();

            $table->index(['product_id', 'harvest_date']);
            $table->index('created_by_uid');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_harvest_results');
    }
};
