<?php

namespace App\Models;

class Sale extends Model
{
    protected $fillable = [
        'date', 'sale_type', 'status', 'source_from',
        'distributor_id', 'retailer_id',
        'province_id', 'district_id', 'village_id',
        'notes', 'total_amount', 'released_datetime', 'released_by_uid',
    ];

    protected $casts = [
        'date'           => 'date',
        'total_amount'   => 'float',
        'released_datetime' => 'datetime',
        'distributor_id' => 'integer',
        'retailer_id'    => 'integer',
        'province_id'    => 'integer',
        'district_id'    => 'integer',
        'village_id'     => 'integer',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
        'released_by_uid' => 'integer',
    ];

    public const Type_Retailer    = 'retailer';
    public const Type_Distributor = 'distributor';
    public const Status_Pending   = 'pending';
    public const Status_Released  = 'released';
    public const Source_Distributor = 'distributor';
    public const Source_R1          = 'r1';

    public function distributor()
    {
        return $this->belongsTo(Customer::class, 'distributor_id');
    }

    public function retailer()
    {
        return $this->belongsTo(Customer::class, 'retailer_id');
    }

    public function province()
    {
        return $this->belongsTo(Province::class);
    }

    public function district()
    {
        return $this->belongsTo(District::class);
    }

    public function village()
    {
        return $this->belongsTo(Village::class);
    }

    public function items()
    {
        return $this->hasMany(SaleItem::class);
    }

    public function created_by_user()
    {
        return $this->belongsTo(User::class, 'created_by_uid');
    }

    public function updated_by_user()
    {
        return $this->belongsTo(User::class, 'updated_by_uid');
    }

    public function released_by_user()
    {
        return $this->belongsTo(User::class, 'released_by_uid');
    }
}
