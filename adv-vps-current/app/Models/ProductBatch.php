<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductBatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'product_name',
        'batch_number',
        'production_date',
        'distribution_area',
    ];

    protected $casts = [
        'product_id' => 'integer',
        'production_date' => 'date',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    public function complaints()
    {
        return $this->hasMany(Complaint::class, 'batch_id');
    }
}
