<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductHarvestResultPhoto extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'product_harvest_result_id',
        'image_path',
        'sort_order',
        'created_datetime',
        'created_by_uid',
    ];

    protected $casts = [
        'product_harvest_result_id' => 'integer',
        'sort_order' => 'integer',
        'created_by_uid' => 'integer',
    ];

    protected static function booted(): void
    {
        static::creating(function (self $model) {
            $model->created_datetime = now();
            $model->created_by_uid = auth()->id();
        });
    }

    public function harvestResult()
    {
        return $this->belongsTo(ProductHarvestResult::class, 'product_harvest_result_id');
    }
}
