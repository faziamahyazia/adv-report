<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_harvest_result_photos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('product_harvest_result_id');
            $table->string('image_path', 500);
            $table->unsignedInteger('sort_order')->default(0);
            $table->dateTime('created_datetime')->nullable();
            $table->unsignedBigInteger('created_by_uid')->nullable();

            $table->foreign('product_harvest_result_id', 'phr_photos_harvest_fk')
                ->references('id')
                ->on('product_harvest_results')
                ->onDelete('cascade');

            $table->index(['product_harvest_result_id', 'sort_order'], 'phr_photos_sort_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_harvest_result_photos');
    }
};
