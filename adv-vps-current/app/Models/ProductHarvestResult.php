<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductHarvestResult extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'harvest_date',
        'harvest_age_days',
        'harvest_quantity',
        'harvest_unit',
        'per_piece_quantity',
        'is_multiple_harvest',
        'farmer_name',
        'land_area',
        'total_pieces',
        'location',
        'strengths',
        'weaknesses',
        'notes',
        'photo_path',
    ];

    protected $casts = [
        'product_id' => 'integer',
        'harvest_date' => 'date',
        'harvest_age_days' => 'integer',
        'harvest_quantity' => 'float',
        'per_piece_quantity' => 'float',
        'is_multiple_harvest' => 'boolean',
        'land_area' => 'float',
        'total_pieces' => 'float',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by_uid');
    }
}
