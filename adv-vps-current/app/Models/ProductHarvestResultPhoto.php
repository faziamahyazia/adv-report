<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductHarvestResultPhoto extends Model
{
    public const TYPE_GENERAL = 'general';
    public const TYPE_WEAKNESS = 'weakness';

    public $timestamps = false;

    protected $fillable = [
        'product_harvest_result_id',
        'image_path',
        'sort_order',
        'photo_type',
        'created_datetime',
        'created_by_uid',
    ];

    protected $casts = [
        'product_harvest_result_id' => 'integer',
        'sort_order' => 'integer',
        'photo_type' => 'string',
        'created_by_uid' => 'integer',
    ];

    protected static function booted(): void
    {
        static::creating(function (self $model) {
            if (!$model->photo_type) {
                $model->photo_type = self::TYPE_GENERAL;
            }
            $model->created_datetime = now();
            $model->created_by_uid = auth()->id();
        });
    }

    public function harvestResult()
    {
        return $this->belongsTo(ProductHarvestResult::class, 'product_harvest_result_id');
    }
}
