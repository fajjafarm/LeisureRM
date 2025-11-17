# 05-LayoutSidebar.ps1
# # # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# resources/views/layouts/app.blade.php (Beautiful, mobile-first, dark-mode ready)
@'
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.name') }} - @yield('title', 'Dashboard')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body class="bg-gray-100 dark:bg-gray-900 text-gray-900 dark:text-gray-100 font-sans antialiased min-h-screen flex flex-col md:flex-row">
    <!-- Mobile menu button -->
    <div class="md:hidden fixed bottom-4 right-4 z-50">
        <button @click="sidebarOpen = !sidebarOpen" class="bg-blue-600 hover:bg-blue-700 text-white p-4 rounded-full shadow-lg">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>
    </div>

    <!-- Dynamic Sidebar -->
    <aside x-data="{ sidebarOpen: false }" :class="{ 'translate-x-0': sidebarOpen, '-translate-x-full': !sidebarOpen }" class="fixed md:relative inset-y-0 left-0 z-40 w-72 bg-white dark:bg-gray-800 shadow-xl transform transition-transform duration-300 ease-in-out md:translate-x-0">
        <div class="p-6 border-b dark:border-gray-700">
            <h1 class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ config('app.name') }}</h1>
            <p class="text-sm text-gray-600 dark:text-gray-400">UK H&S Compliant</p>
        </div>
        @livewire('sidebar')
    </aside>

    <!-- Overlay for mobile -->
    <div x-show="sidebarOpen" @click="sidebarOpen = false" class="fixed inset-0 bg-black bg-opacity-50 z-30 md:hidden"></div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col">
        <header class="bg-white dark:bg-gray-800 shadow-sm px-6 py-4 flex justify-between items-center">
            <h2 class="text-2xl font-semibold">@yield('title')</h2>
            <div class="flex items-center space-x-4">
                <span class="text-sm">{{ auth()->user()->name }}</span>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="text-sm text-red-600 hover:text-red-800">Logout</button>
                </form>
            </div>
        </header>

        <main class="flex-1 p-6 overflow-y-auto">
            @if(session('message'))
                <div class="bg-green-100 dark:bg-green-900 border border-green-400 text-green-700 dark:text-green-200 px-4 py-3 rounded mb-6">
                    {{ session('message') }}
                </div>
            @endif
            @yield('content')
        </main>
    </div>

    @livewireScripts
    @stack('scripts')
</body>
</html>
'@ | Out-File -Encoding utf8 resources/views/layouts/app.blade.php

# app/Http/Livewire/Sidebar.php
@'
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
'@ | Out-File -Encoding utf8 app/Http/Livewire/Sidebar.php

# resources/views/livewire/sidebar.blade.php
@'
<div class="py-4">
    <!-- Facility Switcher -->
    <div class="px-6 mb-6">
        <label class="block text-sm font-medium mb-2">Current Facility</label>
        <select wire:model="currentFacility" wire:change="switchFacility($event.target.value)" class="w-full px-3 py-2 border rounded-lg dark:bg-gray-700">
            @foreach($facilities as $f)
                <option value="{{ $f->id }}">{{ $f->name }}</option>
            @endforeach
        </select>
    </div>

    <nav class="space-y-1 px-4">
        <a href="/dashboard" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 {{ request()->is('dashboard') ? 'bg-blue-50 dark:bg-blue-900 text-blue-600' : '' }}">
            <span>🏠 Dashboard</span>
        </a>
        <a href="/tasks" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span>✅ Task Manager</span>
        </a>
        <a href="/pool-testing" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span>🧪 Pool Testing</span>
        </a>
        <a href="/coshh" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span>⚠️ COSHH</span>
        </a>
        <a href="/message-board" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span>📢 Message Board</span>
        </a>

        @if($subFacilities->count())
            <div class="mt-6 pt-4 border-t dark:border-gray-700">
                <p class="px-4 text-xs font-semibold text-gray-500 uppercase">Sub-Facilities</p>
                @foreach($subFacilities as $sub)
                    <a href="#" class="flex items-center px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 rounded">
                        {{ $sub->name }} <span class="ml-auto text-xs">{{ $sub->type }}</span>
                    </a>
                @endforeach
            </div>
        @endif
    </nav>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/sidebar.blade.php

Write-Host "05 - Gorgeous responsive Tailwind layout + dynamic facility sidebar created" -ForegroundColor Green
Write-Host "   Mobile hamburger menu, dark mode, Alpine.js powered — no Osen needed!" -ForegroundColor Cyan
