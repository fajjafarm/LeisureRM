<?php

// File: app/Models/PoolTest.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

class PoolTest extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'user_id',
        'temperature',
        'ph',
        'chlorine',
        'alkalinity',
        'calcium_hardness',
        'tds',
        'balance_result',
    ];

    protected static function booted()
    {
        static::creating(function ($model) {
            $model->balance_result = $model->calculateBalance();
        });

        static::updating(function ($model) {
            $model->balance_result = $model->calculateBalance();
        });
    }

    public function subFacility()
    {
        return $this->belongsTo(SubFacility::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function calculateBalance(): float
    {
        $tf = $this->getTemperatureFactor($this->temperature);
        $cf = $this->getCalciumFactor($this->calcium_hardness);
        $af = $this->getAlkalinityFactor($this->alkalinity);
        $result = $this->ph + $tf + $cf + $af - 12.1;

        // Log or notify if out of range
        if ($result < -0.3 || $result > 0.3) {
            Log::warning('Water balance out of range for PoolTest ID: ' . $this->id);
        }

        return $result;
    }

    private function getTemperatureFactor(float $temp): float
    {
        if ($temp <= 32) return 0.0;
        if ($temp <= 37) return 0.1;
        if ($temp <= 46) return 0.2;
        if ($temp <= 53) return 0.3;
        if ($temp <= 60) return 0.4;
        if ($temp <= 66) return 0.5;
        if ($temp <= 76) return 0.6;
        if ($temp <= 84) return 0.7;
        if ($temp <= 94) return 0.8;
        if ($temp <= 105) return 0.9;
        return 1.0; // Approximate for higher
    }

    private function getCalciumFactor(float $calcium): float
    {
        if ($calcium <= 5) return 0.3;
        if ($calcium <= 25) return 1.0;
        if ($calcium <= 50) return 1.3;
        if ($calcium <= 75) return 1.5;
        if ($calcium <= 100) return 1.6;
        if ($calcium <= 150) return 1.8;
        if ($calcium <= 200) return 1.9;
        if ($calcium <= 250) return 2.0;
        if ($calcium <= 300) return 2.1;
        if ($calcium <= 400) return 2.2;
        if ($calcium <= 600) return 2.3;
        if ($calcium <= 800) return 2.4;
        return 2.5; // For higher
    }

    private function getAlkalinityFactor(float $alk): float
    {
        if ($alk <= 5) return 0.7;
        if ($alk <= 25) return 1.4;
        if ($alk <= 50) return 1.7;
        if ($alk <= 75) return 1.9;
        if ($alk <= 100) return 2.0;
        if ($alk <= 125) return 2.1;
        if ($alk <= 150) return 2.2;
        if ($alk <= 200) return 2.3;
        if ($alk <= 250) return 2.4;
        if ($alk <= 300) return 2.5;
        if ($alk <= 400) return 2.6;
        if ($alk <= 800) return 2.9;
        return 3.0; // Approximate
    }
}
