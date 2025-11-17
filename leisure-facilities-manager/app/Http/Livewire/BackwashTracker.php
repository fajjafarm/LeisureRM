<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\SubFacility;
use App\Models\BackwashLog;
use App\Models\Task;

class BackwashTracker extends Component
{
    public $subFacility;

    public function logBackwash()
    {
        BackwashLog::create([
            'sub_facility_id' => $this->subFacility->id,
            'performed_by' => auth()->id(),
            'performed_at' => now()
        ]);

        $this->subFacility->update(['last_backwash_at' => now()]);
        session()->flash('message', 'Backwash logged successfully');
    }

    public function mount($subFacilityId)
    {
        $this->subFacility = SubFacility::findOrFail($subFacilityId);
        if ($this->subFacility->requires_backwash && $this->subFacility->last_backwash_at) {
            $daysSince = now()->diffInDays($this->subFacility->last_backwash_at);
            if ($daysSince >= $this->subFacility->max_backwash_days) {
                Task::firstOrCreate([
                    'sub_facility_id' => $this->subFacility->id,
                    'title' => "Backwash Required â€“ {$this->subFacility->name}"
                ], [
                    'priority' => 'high',
                    'business_id' => auth()->user()->profile->business_id,
                    'created_by' => auth()->id()
                ]);
            }
        }
    }

    public function render()
    {
        return view('livewire.backwash-tracker');
    }
}
