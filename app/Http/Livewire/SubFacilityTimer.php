<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class SubFacilityTimer extends Component
{
    public $subFacility;
    public $minutesLeft;
    public $isOverdue = false;

    public function mount($subFacilityId)
    {
        $this->subFacility = SubFacility::findOrFail($subFacilityId);
        $this->calculateTime();
    }

    public function calculateTime()
    {
        $interval = $this->subFacility->check_interval_minutes ?? 20;
        $last = $this->subFacility->last_checked_at ?? now()->subMinutes($interval + 1);

        $next = $last->addMinutes($interval);
        $diff = now()->diffInMinutes($next, false);

        if ($diff < 0) {
            $this->isOverdue = true;
            $this->minutesLeft = abs($diff);
            $this->createOverdueTask();
        } else {
            $this->isOverdue = false;
            $this->minutesLeft = $diff;
        }
    }

    public function createOverdueTask()
    {
        if (!Task::where('sub_facility_id', $this->subFacility->id)
                 ->whereNull('completed_at')
                 ->where('title', 'like', '%'.$this->subFacility->name.'%overdue%')
                 ->exists()) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->subFacility->id,
                'created_by' => Auth::id(),
                'title' => $this->subFacility->name . ' â€“ Routine Check Overdue!',
                'description' => "Must be checked every {$this->subFacility->check_interval_minutes} minutes.\nLast checked: " . $this->subFacility->last_checked_at?->format('H:i d/m/Y') ?? 'Never',
                'priority' => 'high',
                'due_at' => now()->addMinutes(5)
            ]);
        }
    }

    public function markChecked()
    {
        $this->subFacility->update(['last_checked_at' => now()]);
        $this->calculateTime();
        session()->flash('message', $this->subFacility->name . ' checked at ' . now()->format('H:i'));
    }

    public function render()
    {
        $this->calculateTime();
        return view('livewire.sub-facility-timer');
    }
}
