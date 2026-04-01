<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('sales')) {
            return;
        }

        Schema::create('sales', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->string('sale_type', 20); // 'retailer' | 'distributor'
            $table->foreignId('distributor_id')->constrained('customers');
            $table->foreignId('retailer_id')->nullable()->constrained('customers');
            $table->foreignId('province_id')->nullable()->constrained('provinces');
            $table->foreignId('district_id')->nullable()->constrained('districts');
            $table->foreignId('village_id')->nullable()->constrained('villages');
            $table->text('notes')->nullable();
            $table->decimal('total_amount', 15, 2)->default(0);
            $table->datetime('created_datetime')->nullable();
            $table->datetime('updated_datetime')->nullable();
            $table->foreignId('created_by_uid')->nullable()->constrained('users');
            $table->foreignId('updated_by_uid')->nullable()->constrained('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sales');
    }
};
