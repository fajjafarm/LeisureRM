<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\Facility;
use App\Models\SubFacility;
use Illuminate\Support\Facades\Auth;

class Sidebar extends Component
{
    public $selectedFacilityId;
    public $facilities;
    public $subFacilities = [];

    protected $listeners = ['facilityChanged' => 'loadSubFacilities'];

    public function mount()
    {
        $user = Auth::user();
        $this->facilities = $user->business->facilities;
        $this->selectedFacilityId = $user->profile->current_facility_id ?? $this->facilities->first()->id ?? null;
        $this->loadSubFacilities();
    }

    public function changeFacility($facilityId)
    {
        $user = Auth::user();
        $user->profile->update(['current_facility_id' => $facilityId]);
        $this->selectedFacilityId = $facilityId;
        $this->loadSubFacilities();
        $this->emit('facilityChanged');
    }

    public function loadSubFacilities()
    {
        if ($this->selectedFacilityId) {
            $this->subFacilities = SubFacility::where('facility_id', $this->selectedFacilityId)
                ->orderBy('type')
                ->get()
                ->groupBy('is_thermal_suite' ? 'Thermal Suite' : 'type');
        }
    }

    public function render()
    {
        // Manager can configure visible items via settings, but default to all
        return view('livewire.sidebar', [
            'showCoshh' => true, // From business settings
            'showTasks' => true,
            'showPoolTests' => true,
            // etc.
        ]);
    }
}
