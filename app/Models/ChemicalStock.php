<?php

// File: app/Models/ChemicalStock.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChemicalStock extends Model
{
    use HasFactory;

    protected $fillable = [
        'sub_facility_id',
        'chemical_name',
        'quantity',
        'unit',
        'min_threshold',
    ];

    public function subFacility()
    {
        return $this->belongsTo(SubFacility::class);
    }

    public function isLow(): bool
    {
        return $this->quantity < $this->min_threshold;
    }
}
