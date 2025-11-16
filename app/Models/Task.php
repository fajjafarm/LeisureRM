<?php

// File: app/Models/Task.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'due_date',
        'priority',
        'assigned_to_user_id',
        'assigned_to_rank',
        'status',
        'assigner_id',
    ];

    protected $casts = [
        'due_date' => 'datetime',
        'priority' => 'string',
        'status' => 'string',
    ];

    public function assigner()
    {
        return $this->belongsTo(User::class, 'assigner_id');
    }

    public function assignee()
    {
        return $this->belongsTo(User::class, 'assigned_to_user_id');
    }

    public function assignedToRankPriority()
    {
        $priorities = [
            'Manager' => 5,
            'Deputy Manager' => 4,
            'Assistant Manager' => 3,
            'Supervisor' => 2,
            'Assistant' => 1,
        ];
        return $priorities[$this->assigned_to_rank] ?? 0;
    }
}
