<?php

// File: app/Models/Facility.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Facility extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'business_id'];

    public function business()
    {
        return $this->belongsTo(Business::class);
    }

    public function subFacilities()
    {
        return $this->hasMany(SubFacility::class);
    }

    public function users()
    {
        return $this->belongsToMany(User::class);
    }
}
