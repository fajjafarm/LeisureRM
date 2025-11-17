# 07-Livewire-Part2.ps1
Set-Location leisure-facilities-manager

# app/Http/Livewire/TaskManager.php
@'
<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\Task;
use App\Models\SubFacility;
use Illuminate\Support\Facades\Auth;

class TaskManager extends Component
{
    public $openTasks = [];
    public $completedToday = [];

    protected $listeners = ['taskCompleted' => '$refresh', 'facilityChanged' => '$refresh'];

    public function mount()
    {
        $this->loadTasks();
    }

    public function loadTasks()
    {
        $user = Auth::user();
        $facilityId = $user->profile->current_facility_id;

        $this->openTasks = Task::whereNull('completed_at')
            ->where(function($q) use ($facilityId, $user) {
                $q->where('facility_id', $facilityId)
                  ->orWhereNull('facility_id')
                  ->orWhere('assigned_to', $user->id);
            })
            ->with(['subFacility', 'assignedTo'])
            ->orderByRaw("FIELD(priority, 'critical', 'high', 'medium', 'low')")
            ->get();

        $this->completedToday = Task::whereDate('completed_at', today())
            ->where('facility_id', $facilityId)
            ->count();
    }

    public function completeTask($taskId)
    {
        $task = Task::findOrFail($taskId);
        $task->update([
            'completed_at' => now(),
            'completed_by' => Auth::id()
        ]);

        $this->emit('taskCompleted');
        $this->loadTasks();
    }

    public function render()
    {
        return view('livewire.task-manager');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/TaskManager.php

# resources/views/livewire/task-manager.blade.php
@'
<div>
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
        <h2 class="text-2xl font-bold mb-4">Task Manager</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div class="bg-red-100 dark:bg-red-900 p-4 rounded">
                <p class="text-3xl font-bold text-red-600">{{ $openTasks->where('priority', 'critical')->count() }}</p>
                <p>Critical Tasks</p>
            </div>
            <div class="bg-yellow-100 dark:bg-yellow-900 p-4 rounded">
                <p class="text-3xl font-bold text-yellow-600">{{ $openTasks->whereIn('priority', ['high','medium'])->count() }}</p>
                <p>Pending Tasks</p>
            </div>
            <div class="bg-green-100 dark:bg-green-900 p-4 rounded">
                <p class="text-3xl font-bold text-green-600">{{ $completedToday }}</p>
                <p>Completed Today</p>
            </div>
        </div>

        <div class="space-y-3">
            @forelse($openTasks as $task)
                <div class="border-l-4 {{ $task->priority == 'critical' ? 'border-red-500' : ($task->priority == 'high' ? 'border-orange-500' : 'border-gray-400') }} bg-gray-50 dark:bg-gray-700 p-4 rounded-r">
                    <div class="flex justify-between items-start">
                        <div>
                            <h4 class="font-bold">{{ $task->title }}</h4>
                            @if($task->subFacility)
                                <span class="text-sm text-gray-600">{{ $task->subFacility->name }} ({{ $task->subFacility->type }})</span>
                            @endif
                            <p class="text-sm mt-1">{{ $task->description }}</p>
                            @if($task->due_at)
                                <p class="text-xs text-red-600">Due: {{ $task->due_at->format('d/m/Y H:i') }}</p>
                            @endif
                        </div>
                        <button wire:click="completeTask({{ $task->id }})"
                                class="ml-4 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded text-sm">
                            Complete
                        </button>
                    </div>
                </div>
            @empty
                <p class="text-center text-gray-500 py-8">No open tasks – well done!</p>
            @endforelse
        </div>
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/task-manager.blade.php

# app/Http/Livewire/PoolTesting.php (PWTAG compliant with auto-task creation)
@'
<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\SubFacility;
use App\Models\PoolTest;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class PoolTesting extends Component
{
    public $subFacilities;
    public $selectedSubFacility;
    public $form = [
        'temperature' => null, 'free_chlorine' => null, 'total_chlorine' => null,
        'ph' => null, 'alkalinity' => null, 'calcium_hardness' => null, 'cyanuric_acid' => null, 'notes' => ''
    ];

    public function mount()
    {
        $this->subFacilities = SubFacility::where('facility_id', Auth::user()->profile->current_facility_id)
            ->whereIn('type', ['pool','baby_pool','hot_tub','turbo_spa','plunge_pool'])
            ->get();
        $this->selectedSubFacility = $this->subFacilities->first()->id ?? null;
    }

    public function submitTest()
    {
        $sub = SubFacility::findOrFail($this->selectedSubFacility);
        $rules = $sub->parameter_rules;

        $outOfRange = false;
        $issues = [];

        foreach ($this->form as $key => $value) {
            if ($value !== null && isset($rules[$key])) {
                if (isset($rules[$key]['min']) && $value < $rules[$key]['min']) {
                    $outOfRange = true;
                    $issues[] = ucfirst(str_replace('_', ' ', $key)) . " too low ($value < {$rules[$key]['min']})";
                }
                if (isset($rules[$key]['max']) && $value > $rules[$key]['max']) {
                    $outOfRange = true;
                    $issues[] = ucfirst(str_replace('_', ' ', $key)) . " too high ($value > {$rules[$key]['max']})";
                }
            }
        }

        $test = PoolTest::create([
            'sub_facility_id' => $this->selectedSubFacility,
            'user_id' => Auth::id(),
            'is_out_of_range' => $outOfRange,
            'notes' => $this->form['notes'],
            'tested_at' => now(),
        ] + $this->form);

        if ($outOfRange) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->selectedSubFacility,
                'created_by' => Auth::id(),
                'title' => 'Pool Test Out of Range – Action Required',
                'description' => "Pool: {$sub->name}\nIssues:\n• " . implode("\n• ", $issues),
                'priority' => 'critical',
                'due_at' => now()->addHours(2)
            ]);
        }

        $this->reset('form');
        session()->flash('message', 'Pool test recorded successfully' . ($outOfRange ? ' – Critical task created' : ''));
    }

    public function render()
    {
        return view('livewire.pool-testing');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/PoolTesting.php

# resources/views/livewire/pool-testing.blade.php (mobile-optimized)
@'
<div class="max-w-2xl mx-auto">
    <h2 class="text-2xl font-bold mb-6">Pool Water Testing</h2>

    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <select wire:model="selectedSubFacility" class="w-full p-3 border rounded mb-6">
            @foreach($subFacilities as $sub)
                <option value="{{ $sub->id }}">{{ $sub->name }} ({{ ucwords(str_replace('_', ' ', $sub->type)) }})</option>
            @endforeach
        </select>

        <form wire:submit.prevent="submitTest" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <x-input label="Temperature (°C)" wire:model="form.temperature" type="number" step="0.1" required />
                <x-input label="Free Chlorine (mg/L)" wire:model="form.free_chlorine" type="number" step="0.1" required />
                <x-input label="Total Chlorine (mg/L)" wire:model="form.total_chlorine" type="number" step="0.1" />
                <x-input label="pH" wire:model="form.ph" type="number" step="0.01" required />
                <x-input label="Alkalinity (mg/L)" wire:model="form.alkalinity" type="number" step="1" />
                <x-input label="Calcium Hardness (mg/L)" wire:model="form.calcium_hardness" type="number" step="1" />
                <x-input label="Cyanuric Acid (mg/L)" wire:model="form.cyanuric_acid" type="number" step="1" />
            </div>

            <x-textarea label="Notes" wire:model="form.notes" rows="3" />

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded">
                Record Test
            </button>
        </form>

        @if(session()->has('message'))
            <div class="mt-4 p-4 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded">
                {{ session('message') }}
            </div>
        @endif
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/pool-testing.blade.php

Write-Host "07 - Task Manager & PWTAG-compliant Pool Testing with auto-task creation completed"