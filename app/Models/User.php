<?php

// File: app/Models/User.php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'password',
        'rank',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'rank' => 'string', // enum in migration
    ];

    public function businesses()
    {
        return $this->belongsToMany(Business::class);
    }

    public function tasksAsAssigner()
    {
        return $this->hasMany(Task::class, 'assigner_id');
    }

    public function tasksAsAssignee()
    {
        return $this->hasMany(Task::class, 'assigned_to_user_id');
    }

    // Helper for rank priority
    public function rankPriority()
    {
        $priorities = [
            'Manager' => 5,
            'Deputy Manager' => 4,
            'Assistant Manager' => 3,
            'Supervisor' => 2,
            'Assistant' => 1,
            null => 0,
        ];
        return $priorities[$this->rank] ?? 0;
    }
}
