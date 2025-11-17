# 06-Livewire-Part1.ps1
Set-Location leisure-facilities-manager

# resources/views/layouts/app.blade.php (Responsive with Breeze + Blaze styles, mobile-first)
@'
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ env('APP_NAME') }} - @yield('title')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
</head>
<body class="antialiased font-sans bg-gray-100 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
    <div class="min-h-screen flex flex-col md:flex-row">
        <!-- Dynamic Sidebar -->
        <aside class="w-full md:w-64 bg-white dark:bg-gray-800 shadow-md overflow-y-auto">
            @livewire('sidebar')
        </aside>

        <!-- Main Content -->
        <main class="flex-1 p-6">
            @yield('content')
        </main>
    </div>
    @livewireScripts
</body>
</html>
'@ | Out-File -Encoding utf8 resources/views/layouts/app.blade.php

# app/Http/Livewire/Sidebar.php (Dynamic, Manager-configurable, Facility-specific)
@'
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
'@ | Out-File -Encoding utf8 app/Http/Livewire/Sidebar.php

# resources/views/livewire/sidebar.blade.php
@'
<nav class="p-4">
    <div class="mb-6">
        <label class="block text-sm font-medium mb-2">Current Facility</label>
        <select wire:model="selectedFacilityId" wire:change="changeFacility($event.target.value)" class="w-full p-2 border rounded">
            @foreach($facilities as $facility)
                <option value="{{ $facility->id }}">{{ $facility->name }}</option>
            @endforeach
        </select>
    </div>

    <ul class="space-y-4">
        <li><a href="{{ route('dashboard') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Dashboard</a></li>
        <li><a href="{{ route('tasks.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Task Manager</a></li>
        <li><a href="{{ route('staff.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Staff Management</a></li>
        <li><a href="{{ route('coshh.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">COSHH</a></li>
        <li><a href="{{ route('pool-tests.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Pool Testing</a></li>
        <li><a href="{{ route('water-meters.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Water Meters</a></li>
        <li><a href="{{ route('inventory.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Inventory</a></li>
        <li><a href="{{ route('club-hires.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Club Hires</a></li>
        <li><a href="{{ route('message-board') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Message Board</a></li>
        <li><a href="{{ route('safety-checklists.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Safety Inspections</a></li>
        
        <!-- Dynamic Sub-Facilities -->
        @if(!empty($subFacilities))
            <li class="mt-4 font-bold">Facilities</li>
            @foreach($subFacilities as $group => $subs)
                <li class="ml-2">{{ $group }}</li>
                @foreach($subs as $sub)
                    <li class="ml-4"><a href="{{ route('sub-facility.show', $sub->id) }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-1 rounded text-sm">{{ $sub->name }}</a></li>
                @endforeach
            @endforeach
        @endif
    </ul>
</nav>
'@ | Out-File -Encoding utf8 resources/views/livewire/sidebar.blade.php

# app/Http/Livewire/FacilitySwitcher.php (Quick switch for mobile)
@'
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
'@ | Out-File -Encoding utf8 app/Http/Livewire/FacilitySwitcher.php

# resources/views/livewire/facility-switcher.blade.php
@'
<div class="md:hidden fixed bottom-0 left-0 right-0 bg-white p-4 shadow-md">
    <select wire:model="currentFacility.id" class="w-full p-2 border rounded">
        @foreach($facilities as $facility)
            <option value="{{ $facility->id }}">{{ $facility->name }}</option>
        @endforeach
    </select>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/facility-switcher.blade.php

Write-Host "06 - Base layout, dynamic sidebar, facility switcher Livewire components created (responsive for mobile)"