<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class SubFacilityCheckTimer extends Component
{
    public $subFacility;
    public $minutesRemaining;
    public $isOverdue = false;

    protected $listeners = ['refreshCheck' => '$refresh'];

    public function mount($subFacilityId)
    {
        $this->subFacility = SubFacility::findOrFail($subFacilityId);
        $this->calculateTime();
        $this->startPolling();
    }

    public function startPolling()
    {
        $this->dispatchBrowserEvent('start-timer', [
            'interval' => $this->subFacility->check_interval_minutes * 60 * 1000 // ms
        ]);
    }

    public function calculateTime()
    {
        if (!$this->subFacility->last_checked_at) {
            $this->minutesRemaining = $this->subFacility->check_interval_minutes ?? 0;
            $this->isOverdue = true;
            return;
        }

        $nextCheck = $this->subFacility->last_checked_at->addMinutes($this->subFacility->check_interval_minutes);
        $diff = now()->diffInMinutes($nextCheck, false);

        if ($diff < 0) {
            $this->isOverdue = true;
            $this->minutesRemaining = abs($diff);
            $this->createOverdueTask();
        } else {
            $this->minutesRemaining = $diff;
            $this->isOverdue = false;
        }
    }

    public function createOverdueTask()
    {
        if (!Task::where('sub_facility_id', $this->subFacility->id)
                 ->whereNull('completed_at')
                 ->where('title', 'like', '%'.$this->subFacility->name.'%check overdue%')
                 ->exists()) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->subFacility->id,
                'created_by' => Auth::id(),
                'title' => $this->subFacility->name . ' â€“ Routine Check Overdue',
                'description' => "This facility requires checking every {$this->subFacility->check_interval_minutes} minutes.\nLast checked: " . ($this->subFacility->last_checked_at?->format('d/m/Y H:i') ?? 'Never'),
                'priority' => 'high',
                'due_at' => now()->addMinutes(5)
            ]);
        }
    }

    public function markChecked()
    {
        $this->subFacility->update(['last_checked_at' => now()]);
        $this->calculateTime();
        $this->emit('refreshCheck');
        session()->flash('message', $this->subFacility->name . ' checked at ' . now()->format('H:i'));
    }

    public function render()
    {
        $this->calculateTime(); // real-time update
        return view('livewire.sub-facility-check-timer');
    }
}
