<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\Facility;
use Illuminate\Support\Facades\Auth;

class FacilitySwitcher extends Component
{
    public $currentFacility;

    public function mount()
    {
        $this->currentFacility = Auth::user()->currentFacility;
    }

    public function render()
    {
        return view('livewire.facility-switcher', [
            'facilities' => Auth::user()->business->facilities
        ]);
    }
}
