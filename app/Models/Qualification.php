<?php

// File: app/Models/Qualification.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Qualification extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description'];

    public function requiredRanks()
    {
        return $this->belongsToMany(User::class, 'qualification_rank', 'qualification_id', 'rank')
            ->withPivot('required'); // Note: rank is string, so custom pivot
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_qualifications')
            ->withPivot('obtained_date', 'expiry_date');
    }
}
