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
        'harvest_cycles',
        'demo_plot_id',
        'farmer_name',
        'land_area',
        'altitude_mdpl',
        'total_pieces',
        'germination_percentage',
        'location',
        'strengths',
        'weaknesses',
        'notes',
        'photo_path',
        'created_datetime',
        'created_by_uid',
        'updated_datetime',
        'updated_by_uid',
    ];

    protected $casts = [
        'product_id' => 'integer',
        'harvest_date' => 'date',
        'harvest_age_days' => 'integer',
        'harvest_quantity' => 'float',
        'per_piece_quantity' => 'float',
        'is_multiple_harvest' => 'boolean',
        'harvest_cycles' => 'array',
        'demo_plot_id' => 'integer',
        'land_area' => 'float',
        'altitude_mdpl' => 'integer',
        'total_pieces' => 'float',
        'germination_percentage' => 'float',
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

    public function demoPlot()
    {
        return $this->belongsTo(DemoPlot::class, 'demo_plot_id');
    }
}
