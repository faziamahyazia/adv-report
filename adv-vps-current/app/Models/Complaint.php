<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class Complaint extends Model
{
    use HasFactory;

    public const Category_RebahSemai = 'rebah_semai';
    public const Category_PertumbuhanLambat = 'pertumbuhan_lambat';
    public const Category_KeseragamanJelek = 'keseragaman_jelek';
    public const Category_VigorJelek = 'vigor_jelek';
    public const Category_DayaTumbuhRendah = 'daya_tumbuh_rendah';
    public const Category_Bulai = 'bulai';
    public const Category_BusukBatang = 'busuk_batang';
    public const Category_Other = 'other';

    public const Severity_Low = 'low';
    public const Severity_Medium = 'medium';
    public const Severity_High = 'high';

    public const Status_Open = 'open';
    public const Status_InProgress = 'in_progress';
    public const Status_Resolved = 'resolved';
    public const Status_Closed = 'closed';

    public const Categories = [
        self::Category_RebahSemai => 'Rebah Semai',
        self::Category_PertumbuhanLambat => 'Pertumbuhan Lambat',
        self::Category_KeseragamanJelek => 'Keseragaman Jelek',
        self::Category_VigorJelek => 'Vigor Jelek',
        self::Category_DayaTumbuhRendah => 'Daya Tumbuh Rendah',
        self::Category_Bulai => 'Bulai',
        self::Category_BusukBatang => 'Busuk Batang',
        self::Category_Other => 'Lainnya',
    ];

    public const Severities = [
        self::Severity_Low => 'Low',
        self::Severity_Medium => 'Medium',
        self::Severity_High => 'High',
    ];

    public const Statuses = [
        self::Status_Open => 'Open',
        self::Status_InProgress => 'In Progress',
        self::Status_Resolved => 'Resolved',
        self::Status_Closed => 'Closed',
    ];

    protected $fillable = [
        'title',
        'reporter_name',
        'category',
        'description',
        'product_id',
        'product_name',
        'batch_id',
        'bs_id',
        'agronomist_id',
        'location',
        'latitude',
        'longitude',
        'region',
        'severity',
        'status',
        'ai_result',
        'sla_hours',
        'responded_datetime',
        'resolved_datetime',
        'response_time_hours',
        'resolution_time_hours',
        'is_valid',
        'source',
    ];

    protected $casts = [
        'product_id' => 'integer',
        'batch_id' => 'integer',
        'bs_id' => 'integer',
        'agronomist_id' => 'integer',
        'latitude' => 'float',
        'longitude' => 'float',
        'sla_hours' => 'integer',
        'responded_datetime' => 'datetime',
        'resolved_datetime' => 'datetime',
        'response_time_hours' => 'float',
        'resolution_time_hours' => 'float',
        'is_valid' => 'boolean',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    public function batch()
    {
        return $this->belongsTo(ProductBatch::class, 'batch_id');
    }

    public function bs()
    {
        return $this->belongsTo(User::class, 'bs_id');
    }

    public function agronomist()
    {
        return $this->belongsTo(User::class, 'agronomist_id');
    }

    public function images()
    {
        return $this->hasMany(ComplaintImage::class, 'complaint_id');
    }

    public function logs()
    {
        return $this->hasMany(ComplaintLog::class, 'complaint_id');
    }
}
