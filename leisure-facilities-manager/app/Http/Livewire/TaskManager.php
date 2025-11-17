<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\Task;
use App\Models\SubFacility;
use Illuminate\Support\Facades\Auth;

class TaskManager extends Component
{
    public $openTasks = [];
    public $completedToday = [];

    protected $listeners = ['taskCompleted' => '$refresh', 'facilityChanged' => '$refresh'];

    public function mount()
    {
        $this->loadTasks();
    }

    public function loadTasks()
    {
        $user = Auth::user();
        $facilityId = $user->profile->current_facility_id;

        $this->openTasks = Task::whereNull('completed_at')
            ->where(function($q) use ($facilityId, $user) {
                $q->where('facility_id', $facilityId)
                  ->orWhereNull('facility_id')
                  ->orWhere('assigned_to', $user->id);
            })
            ->with(['subFacility', 'assignedTo'])
            ->orderByRaw("FIELD(priority, 'critical', 'high', 'medium', 'low')")
            ->get();

        $this->completedToday = Task::whereDate('completed_at', today())
            ->where('facility_id', $facilityId)
            ->count();
    }

    public function completeTask($taskId)
    {
        $task = Task::findOrFail($taskId);
        $task->update([
            'completed_at' => now(),
            'completed_by' => Auth::id()
        ]);

        $this->emit('taskCompleted');
        $this->loadTasks();
    }

    public function render()
    {
        return view('livewire.task-manager');
    }
}
