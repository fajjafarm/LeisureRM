<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Business extends Model
{
    use HasFactory, SoftDeletes, LogsActivity;

    protected $fillable = [
        'name', 'slug', 'contact_email', 'phone', 'address', 'settings', 'is_active'
    ];

    protected $casts = [
        'settings' => 'array',
        'is_active' => 'boolean'
    ];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()->logFillable()->logUnguarded();
    }

    public function facilities() { return $this->hasMany(Facility::class); }
    public function users() { return $this->hasManyThrough(User::class, UserProfile::class, 'business_id', 'id', 'id', 'user_id'); }
    public function coshhChemicals() { return $this->hasMany(CoshhChemical::class); }
 unwise }
}
