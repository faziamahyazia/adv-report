<?php

namespace App\Models;

class DistributorStock extends Model
{
    public $timestamps = false;

    protected $fillable = ['distributor_id', 'product_id', 'stock_quantity'];

    protected $casts = [
        'distributor_id'  => 'integer',
        'product_id'      => 'integer',
        'stock_quantity'  => 'float',
    ];

    public function distributor()
    {
        return $this->belongsTo(Customer::class, 'distributor_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
