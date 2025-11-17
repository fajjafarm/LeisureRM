<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class TaskManager extends Component
{
    public $tasks;

    protected $listeners = ['taskCompleted' => '$refresh', 'facilityChanged' => '$refresh'];

    public function mount()
    {
        $this->loadTasks();
    }

    public function loadTasks()
    {
        $facilityId = Auth::user()->profile?->current_facility_id;

        $this->tasks = Task::whereNull('completed_at')
            ->where(function($q) use ($facilityId) {
                $q->where('facility_id', $facilityId)
                  ->orWhereNull('facility_id');
            })
            ->with(['subFacility', 'assignedTo'])
            ->orderByRaw("FIELD(priority, 'critical', 'high', 'medium', 'low')")
            ->get();
    }

    public function completeTask($id)
    {
        $task = Task::find($id);
        $task->update([
            'completed_at' => now(),
            'completed_by' => Auth::id()
        ]);
        $this->loadTasks();
    }

    public function render()
    {
        return view('livewire.task-manager');
    }
}
