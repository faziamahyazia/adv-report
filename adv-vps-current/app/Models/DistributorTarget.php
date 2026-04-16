<?php

namespace App\Models;

class DistributorTarget extends Model
{
    public const MONTH_COLUMNS = [
        'apr_qty' => 'Apr',
        'may_qty' => 'Mei',
        'jun_qty' => 'Jun',
        'jul_qty' => 'Jul',
        'aug_qty' => 'Agu',
        'sep_qty' => 'Sep',
        'oct_qty' => 'Okt',
        'nov_qty' => 'Nov',
        'dec_qty' => 'Des',
        'jan_qty' => 'Jan',
        'feb_qty' => 'Feb',
        'mar_qty' => 'Mar',
    ];

    protected $fillable = [
        'distributor_id',
        'product_id',
        'fiscal_year',
        'month',
        'target_qty',
        'actual_qty',
        'total_target_qty',
        'apr_qty',
        'may_qty',
        'jun_qty',
        'jul_qty',
        'aug_qty',
        'sep_qty',
        'oct_qty',
        'nov_qty',
        'dec_qty',
        'jan_qty',
        'feb_qty',
        'mar_qty',
        'notes',
    ];

    protected $casts = [
        'distributor_id' => 'integer',
        'product_id' => 'integer',
        'fiscal_year' => 'integer',
        'month' => 'integer',
        'target_qty' => 'float',
        'actual_qty' => 'float',
        'total_target_qty' => 'float',
        'apr_qty' => 'float',
        'may_qty' => 'float',
        'jun_qty' => 'float',
        'jul_qty' => 'float',
        'aug_qty' => 'float',
        'sep_qty' => 'float',
        'oct_qty' => 'float',
        'nov_qty' => 'float',
        'dec_qty' => 'float',
        'jan_qty' => 'float',
        'feb_qty' => 'float',
        'mar_qty' => 'float',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function distributor()
    {
        return $this->belongsTo(Customer::class, 'distributor_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public static function monthColumns(): array
    {
        return self::MONTH_COLUMNS;
    }
}