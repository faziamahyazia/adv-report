<?php

namespace App\Models;

class Village extends Model
{
    public $timestamps = false;

    protected $fillable = ['district_id', 'name'];

    protected $casts = ['district_id' => 'integer'];

    public function district()
    {
        return $this->belongsTo(District::class);
    }
}
