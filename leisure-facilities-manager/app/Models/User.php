<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Spatie\Permission\Traits\HasRoles;
use Spatie\Activitylog\Traits\LogsActivity;

class User extends Authenticatable
{
    use Notifiable, HasRoles, LogsActivity;

    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];

    public function profile() { return $this->hasOne(UserProfile::class); }
    public function currentFacility()
    {
        return $this->hasOneThrough(
            Facility::class,
            UserProfile::class,
            'user_id',
            'id',
            'id',
            'current_facility_id'
        );
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole('super-admin');
    }
}
