<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubFacility extends Model
{
    protected $fillable = ['name', 'facility_id', 'check_interval_minutes', 'check_start_time', 'check_end_time', 'max_bather_load'];

    protected $casts = [
        'check_start_time' => 'datetime:H:i',
        'check_end_time' => 'datetime:H:i',
    ];

    public function facility() { return $this->belongsTo(Facility::class); }
    public function poolTests() { return $this->hasMany(PoolTest::class); }
    public function healthChecks() { return $this->hasMany(HealthCheck::class); }
    public function safetyEquipment() { return $this->hasMany(SafetyEquipment::class); }
}
