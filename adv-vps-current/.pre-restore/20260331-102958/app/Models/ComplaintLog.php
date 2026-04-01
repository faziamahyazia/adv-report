<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;

class ComplaintLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'complaint_id',
        'user_id',
        'action',
        'old_status',
        'new_status',
        'notes',
    ];

    protected $casts = [
        'complaint_id' => 'integer',
        'user_id' => 'integer',
        'created_by_uid' => 'integer',
        'updated_by_uid' => 'integer',
    ];

    public function complaint()
    {
        return $this->belongsTo(Complaint::class, 'complaint_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
