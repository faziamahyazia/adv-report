<?php

namespace App\Models;

class StockMovement extends Model
{
    protected $fillable = [
        'distributor_id', 'product_id', 'type', 'quantity', 'reference', 'lot_number', 'expired_date', 'notes',
    ];

    protected $casts = [
        'distributor_id' => 'integer',
        'product_id'     => 'integer',
        'quantity'       => 'float',
        'expired_date'   => 'date',
        'created_by_uid' => 'integer',
    ];

    public const Type_In  = 'in';
    public const Type_Out = 'out';

    public function distributor()
    {
        return $this->belongsTo(Customer::class, 'distributor_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function created_by_user()
    {
        return $this->belongsTo(User::class, 'created_by_uid');
    }
}
