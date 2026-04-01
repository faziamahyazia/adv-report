<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class ComplaintImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'complaint_id',
        'image_path',
        'ai_result',
    ];

    protected $casts = [
        'complaint_id' => 'integer',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function complaint()
    {
        return $this->belongsTo(Complaint::class, 'complaint_id');
    }
}
