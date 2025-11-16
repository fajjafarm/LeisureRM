<?php

// File: app/Models/BackwashLog.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BackwashLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'user_id',
        'date',
        'duration_minutes',
        'water_used',
        'notes',
    ];

    protected $casts = [
        'date' => 'datetime',
    ];

    public function subFacility()
    {
        return $this->belongsTo(SubFacility::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
