<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserProfile extends Model
{
    protected $fillable = [
        'user_id', 'business_id', 'current_facility_id', 'start_date', 'end_date',
        'required_training_hours_per_month', 'training_hours_this_month'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date'
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function business() { return $this->belongsTo(Business::class); }
    public function currentFacility() { return $this->belongsTo(Facility::class, 'current_facility_id'); }
    public function qualifications() { return $this->hasMany(UserQualification::class, 'user_id', 'user_id'); }
}
