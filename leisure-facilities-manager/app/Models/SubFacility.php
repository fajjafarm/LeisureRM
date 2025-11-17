<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class SubFacility extends Model
{
    use SoftDeletes, LogsActivity;

    protected $fillable = [
        'facility_id', 'name', 'type', 'is_thermal_suite', 'check_interval_minutes',
        'last_checked_at', 'parameters', 'requires_backwash', 'max_backwash_days', 'last_backwash_at'
    ];

    protected $casts = [
        'parameters' => 'array',
        'last_checked_at' => 'datetime',
        'last_backwash_at' => 'datetime',
        'is_thermal_suite' => 'boolean',
        'requires_backwash' => 'boolean'
    ];

    // PWTAG-compliant parameter ranges (can be overridden per pool)
    public function getParameterRulesAttribute()
    {
        return match($this->type) {
            'pool', 'baby_pool' => [
                'temperature' => ['min' => 26, 'max' => 32],
                'free_chlorine' => ['min' => 1.0, 'max' => 3.0],
                'ph' => ['min' => 7.2, 'max' => 7.6],
                'alkalinity' => ['min' => 80, 'max' => 200],
                'calcium_hardness' => ['min' => 200, 'max' => 1000],
                'cyanuric_acid' => ['max' => 100]
            ],
            'hot_tub', 'turbo_spa' => [
                'temperature' => ['min' => 36, 'max' => 40],
                'free_chlorine' => ['min' => 3.0, 'max' => 5.0],
                'ph' => ['min' => 7.2, 'max' => 7.8],
            ],
            default => []
        };
    }

    public function facility() { return $this->belongsTo(Facility::class); }
    public function poolTests() { return $this->hasMany(PoolTest::class); }
    public function backwashLogs() { return $this->hasMany(BackwashLog::class); }
    public function tasks() { return $this->hasMany(Task::class); }
}
