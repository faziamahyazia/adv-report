<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('distributor_targets')) {
            return;
        }

        Schema::create('distributor_targets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('distributor_id')->constrained('customers');
            $table->foreignId('product_id')->constrained('products');
            $table->unsignedSmallInteger('fiscal_year');
            $table->decimal('total_target_qty', 12, 2)->default(0);
            $table->decimal('apr_qty', 12, 2)->default(0);
            $table->decimal('may_qty', 12, 2)->default(0);
            $table->decimal('jun_qty', 12, 2)->default(0);
            $table->decimal('jul_qty', 12, 2)->default(0);
            $table->decimal('aug_qty', 12, 2)->default(0);
            $table->decimal('sep_qty', 12, 2)->default(0);
            $table->decimal('oct_qty', 12, 2)->default(0);
            $table->decimal('nov_qty', 12, 2)->default(0);
            $table->decimal('dec_qty', 12, 2)->default(0);
            $table->decimal('jan_qty', 12, 2)->default(0);
            $table->decimal('feb_qty', 12, 2)->default(0);
            $table->decimal('mar_qty', 12, 2)->default(0);
            $table->text('notes')->nullable();
            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users');
            $table->foreignId('updated_by_uid')->nullable()->constrained('users');
            $table->unique(['distributor_id', 'product_id', 'fiscal_year'], 'distributor_targets_unique_period');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('distributor_targets');
    }
};