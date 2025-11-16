<?php

// File: app/Models/HealthCheck.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HealthCheck extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'user_id',
        'notes',
        'status',
    ];

    protected $casts = [
        'status' => 'string', // enum in migration
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
