<?php

namespace App\Models;

class SaleItem extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'sale_id', 'product_id', 'lot_number', 'expired_date', 'quantity', 'unit', 'price', 'subtotal',
    ];

    protected $casts = [
        'sale_id'    => 'integer',
        'product_id' => 'integer',
        'expired_date' => 'date',
        'quantity'   => 'float',
        'price'      => 'float',
        'subtotal'   => 'float',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
