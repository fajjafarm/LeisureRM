<?php

// File: app/Models/TrainingSession.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode; // Assume package installed: composer require simplesoftwareio/simple-qrcode

class TrainingSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'date',
        'type', // e.g., 'CPR', 'General'
        'duration_hours',
        'qr_code',
        'created_by',
    ];

    protected $casts = [
        'date' => 'datetime',
    ];

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function attendances()
    {
        return $this->hasMany(TrainingAttendance::class);
    }

    public function generateQrCode()
    {
        $url = route('training.attend', ['session' => $this->id, 'token' => Str::random(32)]); // Secure with token
        $this->qr_code = QrCode::size(300)->generate($url);
        $this->save();
    }
}
