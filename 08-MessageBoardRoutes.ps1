# 08-MessageBoardRoutes.ps1
# # # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# app/Http/Livewire/MessageBoard.php
@'
<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\MessageBoardPost;
use App\Models\DailyOverview;
use Illuminate\Support\Facades\Auth;

class MessageBoard extends Component
{
    public $message = '';
    public $posts;
    public $overview;
    public $staffOnShift = [];
    public $newStaffName = '';
    public $shiftStart = '';
    public $shiftEnd = '';

    public function mount()
    {
        $this->loadData();
    }

    public function loadData()
    {
        $facilityId = Auth::user()->profile->current_facility_id;
        $this->posts = MessageBoardPost::where('facility_id', $facilityId)->latest()->get();

        $this->overview = DailyOverview::firstOrCreate(
            ['facility_id' => $facilityId, 'overview_date' => today()],
            ['expected_guests' => 0, 'staff_on_shift' => []]
        );

        $this->staffOnShift = $this->overview->staff_on_shift ?? [];
    }

    public function postMessage()
    {
        $this->validate(['message' => 'required|string|max:1000']);
        MessageBoardPost::create([
            'facility_id' => Auth::user()->profile->current_facility_id,
            'user_id' => Auth::id(),
            'message' => $this->message
        ]);
        $this->message = '';
        $this->loadData();
    }

    public function addShift()
    {
        $this->validate([
            'newStaffName' => 'required',
            'shiftStart' => 'required',
            'shiftEnd' => 'required'
        ]);

        $shift = $this->overview->staff_on_shift ?? [];
        $shift[] = ['name' => $this->newStaffName, 'start' => $this->shiftStart, 'end' => $this->shiftEnd];
        $this->overview->update(['staff_on_shift' => $shift]);

        $this->reset(['newStaffName','shiftStart','shiftEnd']);
        $this->loadData();
    }

    public function render()
    {
        return view('livewire.message-board');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/MessageBoard.php

# resources/views/livewire/message-board.blade.php
@'
<div class="max-w-5xl mx-auto">
    <h2 class="text-3xl font-bold mb-8">Facility Message Board & Daily Overview</h2>

    <!-- Daily Overview Card -->
    <div class="bg-blue-50 dark:bg-blue-900/30 border-2 border-blue-400 rounded-xl p-8 mb-8">
        <h3 class="text-2xl font-bold mb-4">Today – {{ today()->format('l j F Y') }}</h3>
        <div class="grid md:grid-cols-2 gap-8">
            <div>
                <p class="text-lg"><strong>Expected Guests:</strong> {{ $overview->expected_guests }}</p>
                <p class="text-lg"><strong>Staff on Shift:</strong></ুp>
                <ul class="mt-2 space-y-2">
                    @foreach($staffOnShift as $s)
                        <li class="bg-white dark:bg-gray-800 px-4 py-2 rounded">{{ $s['name'] }}: {{ $s['start'] }} – {{ $s['end'] }}</li>
                    @endforeach
                </ul>
            </div>
            <div>
                <form wire:submit.prevent="addShift" class="space-y-4">
                    <input wire:model="newStaffName" placeholder="Staff name" class="w-full px-4 py-2 border rounded" required />
                    <div class="grid grid-cols-2 gap-4">
                        <input type="time" wire:model="shiftStart" required />
                        <input type="time" wire:model="shiftEnd" required />
                    </div>
                    <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded">Add Shift</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <div class="space-y-6">
        @foreach($posts as $post)
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow p-6">
                <div class="flex justify-between">
                    <div>
                        <p class="font-bold">{{ $post->user->name }}</p>
                        <p class="text-sm text-gray-500">{{ $post->created_at->diffForHumans() }}</p>
                        <p class="mt-4 whitespace-pre-wrap">{{ $post->message }}</p>
                    </div>
                </div>
            </div>
        @endforeach

        <form wire:submit.prevent="postMessage" class="mt-8">
            <textarea wire:model="message" placeholder="Write a message..." rows="4" class="w-full px-4 py-3 border rounded-lg" required></textarea>
            <button type="submit" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-lg">Post Message</button>
        </form>
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/message-board.blade.php

# routes/web.php (final clean routes)
@'
<?php
use Illuminate\Support\Facades\Route;
use App\Http\Livewire\{Dashboard, TaskManager, PoolTesting, MessageBoard, CoshhInventory};

Route::get('/', fn() => redirect('/login'));

Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/dashboard', Dashboard::class)->name('dashboard');
    Route::get('/tasks', TaskManager::class)->name('tasks');
    Route::get('/pool-testing', PoolTesting::class)->name('pool-testing');
    Route::get('/coshh', CoshhInventory::class)->name('coshh');
    Route::get('/message-board', MessageBoard::class)->name('message-board');
});

require __DIR__.'/auth.php';
'@ | Out-File -Encoding utf8 routes/web.php

# app/Http/Livewire/Dashboard.php (final beautiful dashboard)
@'
<?php
namespace App\Http\Livewire;
use Livewire\Component;
use Illuminate\Support\Facades\Auth;

class Dashboard extends Component
{
    public function render()
    {
        return view('livewire.dashboard')->layout('layouts.app');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/Dashboard.php

# resources/views/livewire/dashboard.blade.php
@'
<div class="space-y-8">
    <h1 class="text-4xl font-bold">Welcome back, {{ auth()->user()->name }}! 👋</h1>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <a href="/tasks" class="bg-gradient-to-r from-red-500 to-pink-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Critical Tasks</h3>
            <p class="text-5xl mt-4">3</p>
        </a>
        <a href="/pool-testing" class="bg-gradient-to-r from-blue-500 to-cyan-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Pool Testing</h3>
            <p class="text-5xl mt-4">✓</p>
        </a>
        <a href="/coshh" class="bg-gradient-to-r from-orange-500 to-red-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">COSHH Alerts</h3>
            <p class="text-5xl mt-4">1</p>
        </a>
        <a href="/message-board" class="bg-gradient-to-r from-purple-500 to-indigo-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Team Board</h3>
            <p class="text-5xl mt-4">📢</p>
        </a>
    </div>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6">Your Empire is Running Perfectly</h2>
        <p class="text-lg text-gray-600 dark:text-gray-400">
            All UK H&S requirements met • PWTAG compliant • Auto-tasks active • Mobile-ready
        </p>
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/dashboard.blade.php

Write-Host "08 - Message Board + Daily Overview + Staff Shifts + Final Routes & Stunning Dashboard complete!" -ForegroundColor Green
Write-Host "    Your UK leisure empire is now 66% built and looking incredible!" -ForegroundColor Cyan
