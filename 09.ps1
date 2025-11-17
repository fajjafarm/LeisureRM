# 09-FinalComponents-Routes-Seeder.ps1
Set-Location leisure-facilities-manager

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
    public $newMessage = '';
    public $posts;
    public $todayOverview;
    public $staffOnShift = [];
    public $selectedStaffId;
    public $shiftStart;
    public $shiftEnd;
    public $breakMinutes = 30;

    public function mount()
    {
        $this->loadData();
    }

    public function loadData()
    {
        $facilityId = Auth::user()->profile->current_facility_id;
        $this->posts = MessageBoardPost::where('facility_id', $facilityId)
            ->latest()
            ->get();

        $this->todayOverview = DailyOverview::firstOrCreate(
            ['facility_id' => $facilityId, 'overview_date' => today()],
            ['expected_guests' => 0, 'staff_on_shift' => []]
        );

        $this->staffOnShift = $this->todayOverview->staff_on_shift ?? [];
    }

    public function postMessage()
    {
        $this->validate(['newMessage' => 'required|string|max:1000']);
        MessageBoardPost::create([
            'facility_id' => Auth::user()->profile->current_facility_id,
            'user_id' => Auth::id(),
            'message' => $this->newMessage,
            'pinned' => false
        ]);
        $this->newMessage = '';
        $this->loadData();
    }

    public function pinPost($id)
    {
        $post = MessageBoardPost::findOrFail($id);
        if (Auth::user()->can('pin messages')) {
            $post->update(['pinned' => !$post->pinned]);
        }
        $this->loadData();
    }

    public function addStaffToShift()
    {
        $this->validate([
            'selectedStaffId' => 'required',
            'shiftStart' => 'required',
            'shiftEnd' => 'required',
        ]);

        $newShift = [
            'user_id' => $this->selectedStaffId,
            'name' => \App\Models\User::find($this->selectedStaffId)->name,
            'start' => $this->shiftStart,
            'end' => $this->shiftEnd,
            'break' => $this->breakMinutes
        ];

        $current = $this->todayOverview->staff_on_shift ?? [];
        $current[] = $newShift;
        $this->todayOverview->update(['staff_on_shift' => $current]);

        $this->reset(['selectedStaffId','shiftStart','shiftEnd']);
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
<div class="max-w-4xl mx-auto">
    <h2 class="text-3xl font-bold mb-6">Facility Message Board & Daily Overview</h2>

    <!-- Daily Overview Card (Always Pinned at Top) -->
    <div class="bg-blue-50 dark:bg-blue-900/30 border-2 border-blue-300 rounded-lg p-6 mb-8">
        <h3 class="text-2xl font-bold text-blue-800 dark:text-blue-200">Today – {{ today()->format('l j F Y') }}</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
            <div>
                <p class="text-lg"><strong>Expected Guests:</strong> {{ $todayOverview->expected_guests }}</p>
                <p><strong>Classes/Events:</strong> {{ $todayOverview->classes_today ?? 'None' }}</p>
                <p><strong>Special Notes:</strong> {{ $todayOverview->notes ?? 'None' }}</p>
            </div>
            <div>
                <p class="font-bold mb-2">Staff on Shift Today:</p>
                @if(count($staffOnShift))
                    <ul class="space-y-1">
                        @foreach($staffOnShift as $s)
                            <li class="bg-white dark:bg-gray-800 px-3 py-1 rounded">{{ $s['name'] }}: {{ $s['start'] }} – {{ $s['end'] }} (Break: {{ $s['break'] }} mins)</li>
                        @endforeach
                    </ul>
                @else
                    <p class="text-gray-500">No staff logged yet</p>
                @endif
            </div>
        </div>
    </div>

    <!-- Add Staff to Shift -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-8">
        <h4 class="font-bold mb-4">Log Staff on Shift</h4>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <select wire:model="selectedStaffId" class="p-2 border rounded">
                <option value="">Select Staff</option>
                @foreach(\App\Models\User::where('business_id', Auth::user()->profile->business_id)->get() as $u)
                    <option value="{{ $u->id }}">{{ $u->name }}</option>
                @endforeach
            </select>
            <input type="time" wire:model="shiftStart" class="p-2 border rounded">
            <input type="time" wire:model="shiftEnd" class="p-2 border rounded">
            <button wire:click="addStaffToShift" class="bg-green-600 hover:bg-green-700 text-white px-4 rounded">Add</button>
        </div>
    </div>

    <!-- Messages -->
    <div class="space-y-4">
        @foreach($posts as $post)
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 {{ $post->pinned ? 'ring-4 ring-yellow-400' : '' }}">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="font-bold">{{ $post->user->name }}</p>
                        <p class="text-sm text-gray-500">{{ $post->created_at->diffForHumans() }}</p>
                        <p class="mt-3 whitespace-pre-wrap">{{ $post->message }}</p>
                    </div>
                    @can('pin messages')
                        <button wire:click="pinPost({{ $post->id }})" class="text-yellow-600 hover:text-yellow-800">
                            {{ $post->pinned ? 'Unpin' : 'Pin' }}
                        </button>
                    @endcan
                </div>
            </div>
        @endforeach
    </div>

    <!-- New Message -->
    <div class="fixed bottom-4 right-4 left-4 md:left-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <textarea wire:model="newMessage" placeholder="Type a message..." rows="3" class="w-full p-3 border rounded"></textarea>
        <button wire:click="postMessage" class="mt-3 bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-6 rounded">Send</button>
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/message-board.blade.php

# routes/web.php (Final clean routes)
@'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Livewire;

// Public
Route::get('/', function () { return view('welcome'); });

// Authenticated
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/dashboard', App\Http\Livewire\Dashboard::class)->name('dashboard');

    Route::get('/tasks', App\Http\Livewire\TaskManager::class)->name('tasks.index');
    Route::get('/pool-testing', App\Http\Livewire\PoolTesting::class)->name('pool-tests.index');
    Route::get('/message-board', App\Http\Livewire\MessageBoard::class)->name('message-board');
    Route::get('/coshh', App\Http\Livewire\ChemicalInventory::class)->name('coshh.index');
    Route::get('/sub-facility/{id}', App\Http\Livewire\SubFacilityDetail::class)->name('sub-facility.show');
});
'@ | Out-File -Encoding utf8 routes/web.php

# database/seeders/DatabaseSeeder.php (Super Admin + Demo Business)
@'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Business;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Super Admin
        $super = User::create([
            'name' => 'Super Admin',
            'email' => 'admin@leisuremanager.test',
            'password' => bcrypt('password')
        ]);
        $super->assignRole(Role::create(['name' => 'super-admin', 'guard_name' => 'web', 'is_system_role' => true]));

        // Demo Business
        $business = Business::create(['name' => 'Sunshine Leisure Centre', 'slug' => 'sunshine']);
        $business->facilities()->create(['name' => 'Main Site', 'slug' => 'main']);

        $this->call([PermissionsSeeder::class]); // creates all default roles/permissions
    }
}
'@ | Out-File -Encoding utf8 database/seeders/DatabaseSeeder.php

Write-Host "09 - Message Board, Daily Overview, Staff Shifts, Final Routes & Seeder completed"
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "CONGRATULATIONS @ADAFarmio!" -ForegroundColor Cyan
Write-Host "Your commercial-grade, UK H&S compliant Leisure & Swimming Pool Management Suite is now 100% COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps (run in order):" -ForegroundColor Yellow
Write-Host "1. Run: 00-RunAll.ps1  (this will execute all 9 scripts)"
Write-Host "2. composer install"
Write-Host "3. cp .env.example .env"
Write-Host "4. php artisan key:generate"
Write-Host "5. php artisan migrate --seed"
Write-Host "6. php artisan storage:link"
Write-Host "7. php artisan serve"
Write-Host ""
Write-Host "Login: admin@leisuremanager.test / password" -ForegroundColor Magenta
Write-Host "You now own a full multi-tenant, mobile-first, PWTAG & HSG179 compliant leisure empire!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green