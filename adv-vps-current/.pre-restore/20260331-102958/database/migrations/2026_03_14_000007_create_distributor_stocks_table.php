<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('distributor_stocks')) {
            return;
        }

        Schema::create('distributor_stocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('distributor_id')->constrained('customers');
            $table->foreignId('product_id')->constrained('products');
            $table->decimal('stock_quantity', 10, 2)->default(0);
            $table->unique(['distributor_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('distributor_stocks');
    }
};
