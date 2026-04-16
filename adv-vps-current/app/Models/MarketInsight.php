<?php

namespace App\Models;

class MarketInsight extends Model
{
    protected $fillable = [
        'bs_user_id',
        'province_id',
        'district_id',
        'product_id',
        'fiscal_year',
        'month',
        'planted_area_ha',
        'seed_need_per_ha_kg',
        'season_count',
        'market_size_seed_kg',
        'market_size_value',
        'market_share_percent',
        'potential_value',
        'potential_notes',
    ];

    protected $casts = [
        'bs_user_id' => 'integer',
        'province_id' => 'integer',
        'district_id' => 'integer',
        'product_id' => 'integer',
        'fiscal_year' => 'integer',
        'month' => 'integer',
        'planted_area_ha' => 'float',
        'seed_need_per_ha_kg' => 'float',
        'season_count' => 'float',
        'market_size_seed_kg' => 'float',
        'market_size_value' => 'float',
        'market_share_percent' => 'float',
        'potential_value' => 'float',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function bsUser()
    {
        return $this->belongsTo(User::class, 'bs_user_id');
    }

    public function province()
    {
        return $this->belongsTo(Province::class, 'province_id');
    }

    public function district()
    {
        return $this->belongsTo(District::class, 'district_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}
