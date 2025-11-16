<?php

// File: app/Models/SubFacility.php (Updated)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubFacility extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'facility_id',
        'check_interval_minutes',
        'check_start_time',
        'check_end_time',
        'normal_daily_usage',
        'backwash_interval_days', // New field
    ];

    protected $casts = [
        'check_start_time' => 'datetime:H:i',
        'check_end_time' => 'datetime:H:i',
    ];

    public function facility()
    {
        return $this->belongsTo(Facility::class);
    }

    public function poolTests()
    {
        return $this->hasMany(PoolTest::class);
    }

    public function healthChecks()
    {
        return $this->hasMany(HealthCheck::class);
    }

    public function chemicalStocks()
    {
        return $this->hasMany(ChemicalStock::class);
    }

    public function waterMeterReadings()
    {
        return $this->hasMany(WaterMeterReading::class);
    }

    public function backwashLogs()
    {
        return $this->hasMany(BackwashLog::class);
    }

    public function annualInspectionItems()
    {
        return $this->hasMany(AnnualInspectionItem::class);
    }
}
