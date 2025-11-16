<?php

// File: app/Http/Controllers/TaskController.php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;

class TaskController extends Controller
{
    public function index()
    {
        $tasks = Task::where('assigned_to_user_id', Auth::id())
            ->orWhere('assigned_to_rank', Auth::user()->rank)
            ->paginate(20);
        return view('tasks.index', compact('tasks'));
    }

    public function create()
    {
        $users = User::all(); // Filter by lower ranks
        $ranks = ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant'];
        return view('tasks.create', compact('users', 'ranks'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'required|in:Low,Medium,High',
            'assigned_to_user_id' => 'nullable|exists:users,id',
            'assigned_to_rank' => 'nullable|in:Manager,Deputy Manager,Assistant Manager,Supervisor,Assistant',
        ]);

        $validated['assigner_id'] = Auth::id();

        $task = Task::create($validated);

        Gate::authorize('assign-task', $task);

        return redirect()->route('tasks.index');
    }

    // Update status, etc.
}
