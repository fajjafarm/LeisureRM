<?php

// File: app/Providers/AuthServiceProvider.php (excerpt for gates)

namespace App\Providers;

// ...

class AuthServiceProvider extends ServiceProvider
{
    // ...

    public function boot()
    {
        Gate::define('assign-task', function ($user, $task) {
            if ($task->assigned_to_user_id) {
                return $user->rankPriority() > $task->assignee->rankPriority();
            }
            return $user->rankPriority() > $task->assignedToRankPriority();
        });

        // e.g., Gate for creating sessions: only managers+
        Gate::define('create-training', function ($user) {
            return $user->rankPriority() >= 3; // Assistant Manager+
        });
    }
}
