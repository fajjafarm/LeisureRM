<?php

// File: app/Models/WaterMeterReading.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class WaterMeterReading extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'date',
        'reading',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function subFacility()
    {
        return $this->belongsTo(SubFacility::class);
    }

    // Get previous reading for usage calculation
    public function getPreviousReading()
    {
        return self::where('sub_facility_id', $this->sub_facility_id)
            ->where('date', '<', $this->date)
            ->orderBy('date', 'desc')
            ->first();
    }

    // Calculate daily usage
    public function getUsageAttribute(): float
    {
        $previous = $this->getPreviousReading();
        return $previous ? $this->reading - $previous->reading : 0;
    }

    // Check if abnormal
    public function isAbnormal(float $normalUsage): bool
    {
        return abs($this->usage - $normalUsage) > 0; // Or add tolerance, e.g., > 10%
    }
}
