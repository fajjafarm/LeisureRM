<?php

// File: app/Models/AnnualInspectionItem.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnnualInspectionItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'name',
        'description',
        'inspection_interval_years',
    ];

    public function subFacility()
    {
        return $this->belongsTo(SubFacility::class);
    }

    public function records()
    {
        return $this->hasMany(AnnualInspectionRecord::class);
    }

    public function lastRecord()
    {
        return $this->records()->latest('date')->first();
    }
}
