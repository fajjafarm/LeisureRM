<?php
namespace App\Http\Livewire;
use Livewire\Component;
use Illuminate\Support\Facades\Auth;

class Sidebar extends Component
{
    public $facilities;
    public $currentFacility;
    public $subFacilities;

    protected $listeners = ['facilityChanged' => '$refresh'];

    public function mount()
    {
        $user = Auth::user();
        $this->facilities = $user->profile?->business?->facilities ?? collect();
        $this->currentFacility = $user->profile?->current_facility_id;
        $this->loadSubFacilities();
    }

    public function switchFacility($id)
    {
        Auth::user()->profile->update(['current_facility_id' => $id]);
        $this->currentFacility = $id;
        $this->loadSubFacilities();
        $this->dispatchBrowserEvent('facility-changed');
    }

    public function loadSubFacilities()
    {
        if ($this->currentFacility) {
            $this->subFacilities = \App\Models\SubFacility::where('facility_id', $this->currentFacility)
                ->orderBy('type')->get();
        } else {
            $this->subFacilities = collect();
        }
    }

    public function render()
    {
        return view('livewire.sidebar');
    }
}
