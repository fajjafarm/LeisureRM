<?php

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

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'rank',               // Manager, Deputy Manager, etc.
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'rank'              => 'string', // or \App\Enums\UserRank::class if you created the enum
    ];

    // ─────────────────────────────────────────────────────────────────
    // Relationships
    // ─────────────────────────────────────────────────────────────────

    public function businesses()
    {
        return $this->belongsToMany(\App\Models\Business::class);
    }

    public function facilities()
    {
        return $this->belongsToMany(\App\Models\Facility::class);
    }

    public function poolTests()
    {
        return $this->hasMany(\App\Models\PoolTest::class);
    }

    public function healthChecks()
    {
        return $this->hasMany(\App\Models\HealthCheck::class);
    }

    // Tasks
    public function tasksAssigned()          // tasks this user created
    {
        return $this->hasMany(\App\Models\Task::class, 'assigned_by');
    }

    public function tasksReceived()          // tasks assigned to this user
    {
        return $this->hasMany(\App\Models\Task::class, 'assigned_to_user_id');
    }

    // ─────────────────────────────────────────────────────────────────
    // Helper for rank hierarchy (used in Task assignment gates)
    // ─────────────────────────────────────────────────────────────────

    public function rankPriority(): int
    {
        return match ($this->rank) {
            'Manager'          => 5,
            'Deputy Manager'   => 4,
            'Assistant Manager'=> 3,
            'Supervisor'       => 2,
            'Assistant'        => 1,
            default            => 0,
        };
    }
}