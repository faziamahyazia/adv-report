<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('stock_movements')) {
            return;
        }

        Schema::create('stock_movements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('distributor_id')->constrained('customers');
            $table->foreignId('product_id')->constrained('products');
            $table->string('type', 10); // 'in' | 'out'
            $table->decimal('quantity', 10, 2);
            $table->string('reference', 100)->nullable();
            $table->text('notes')->nullable();
            $table->datetime('created_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};
