<?php

// File: app/Models/ExternalHireClub.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExternalHireClub extends Model
{
    use HasFactory;

    protected $fillable = [
        'facility_id',
        'name',
        'contact_details', // JSON: e.g., {'phone': '', 'email': ''}
        'safeguarding_contact',
        'notes',
    ];

    protected $casts = [
        'contact_details' => 'array',
    ];

    public function facility()
    {
        return $this->belongsTo(Facility::class);
    }

    public function documents()
    {
        return $this->hasMany(ExternalHireDocument::class);
    }

    // Get current documents
    public function currentDocuments()
    {
        return $this->documents()->where('is_current', true);
    }
}
