<?php

// File: app/Models/TrainingAttendance.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrainingAttendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'training_session_id',
        'user_id',
        'attended_at',
        'score', // For CPR
    ];

    protected $casts = [
        'attended_at' => 'datetime',
    ];

    public function session()
    {
        return $this->belongsTo(TrainingSession::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
