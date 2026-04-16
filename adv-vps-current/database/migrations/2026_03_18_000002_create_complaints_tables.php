<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->string('title', 255);
            $table->enum('category', ['germination', 'growth', 'pest_disease', 'other'])->default('other')->index();
            $table->text('description')->nullable();

            $table->foreignId('product_id')->nullable()->constrained('products')->nullOnDelete();
            $table->string('product_name', 255)->nullable();
            $table->foreignId('batch_id')->nullable()->constrained('product_batches')->nullOnDelete();

            $table->foreignId('bs_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('agronomist_id')->nullable()->constrained('users')->nullOnDelete();

            $table->string('location', 255)->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('region', 255)->nullable();

            $table->enum('severity', ['low', 'medium', 'high'])->default('medium')->index();
            $table->enum('status', ['open', 'in_progress', 'resolved', 'closed'])->default('open')->index();
            $table->text('ai_result')->nullable();

            $table->unsignedInteger('sla_hours')->default(48);
            $table->datetime('responded_datetime')->nullable();
            $table->datetime('resolved_datetime')->nullable();
            $table->decimal('response_time_hours', 10, 2)->nullable();
            $table->decimal('resolution_time_hours', 10, 2)->nullable();
            $table->boolean('is_valid')->nullable();
            $table->enum('source', ['online', 'offline_sync'])->default('online');

            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by_uid')->nullable()->constrained('users')->nullOnDelete();
        });

        Schema::create('complaint_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('complaint_id')->constrained('complaints')->cascadeOnDelete();
            $table->string('image_path', 500);
            $table->text('ai_result')->nullable();

            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by_uid')->nullable()->constrained('users')->nullOnDelete();
        });

        Schema::create('complaint_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('complaint_id')->constrained('complaints')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action', 100);
            $table->string('old_status', 50)->nullable();
            $table->string('new_status', 50)->nullable();
            $table->text('notes')->nullable();

            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by_uid')->nullable()->constrained('users')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaint_logs');
        Schema::dropIfExists('complaint_images');
        Schema::dropIfExists('complaints');
    }
};
