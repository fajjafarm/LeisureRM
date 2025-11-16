<?php

// File: app/Models/ExternalHireDocument.php (New Model for documents)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class ExternalHireDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'external_hire_club_id',
        'type', // enum: 'qualification', 'insurance'
        'file_path',
        'expiry_date',
        'is_current',
    ];

    protected $casts = [
        'expiry_date' => 'date',
        'is_current' => 'boolean',
    ];

    public function club()
    {
        return $this->belongsTo(ExternalHireClub::class);
    }

    // Handle file upload in controller
}
