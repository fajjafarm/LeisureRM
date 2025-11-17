# 06-TasksPoolTesting.ps1
# # # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# app/Http/Livewire/TaskManager.php
@'
<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class TaskManager extends Component
{
    public $tasks;

    protected $listeners = ['taskCompleted' => '$refresh', 'facilityChanged' => '$refresh'];

    public function mount()
    {
        $this->loadTasks();
    }

    public function loadTasks()
    {
        $facilityId = Auth::user()->profile?->current_facility_id;

        $this->tasks = Task::whereNull('completed_at')
            ->where(function($q) use ($facilityId) {
                $q->where('facility_id', $facilityId)
                  ->orWhereNull('facility_id');
            })
            ->with(['subFacility', 'assignedTo'])
            ->orderByRaw("FIELD(priority, 'critical', 'high', 'medium', 'low')")
            ->get();
    }

    public function completeTask($id)
    {
        $task = Task::find($id);
        $task->update([
            'completed_at' => now(),
            'completed_by' => Auth::id()
        ]);
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
<div class="space-y-6">
    <h2 class="text-3xl font-bold mb-6">Task Manager</h2>

    @if($tasks->isEmpty())
        <div class="bg-green-50 dark:bg-green-900 p-8 rounded-lg text-center">
            <p class="text-2xl">🎉 All tasks complete – brilliant work!</p>
        </div>
    @else
        <div class="grid gap-4">
            @foreach($tasks as $task)
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 border-l-8 {{ 
                    $task->priority === 'critical' ? 'border-red-600' : 
                    ($task->priority === 'high' ? 'border-orange-500' : 'border-gray-300')
                }}">
                    <div class="flex justify-between items-start">
                        <div class="flex-1">
                            <h3 class="text-xl font-bold">{{ $task->title }}</h3>
                            @if($task->subFacility)
                                <p class="text-sm text-gray-600">{{ $task->subFacility->name }} ({{ ucwords(str_replace('_', ' ', $task->subFacility->type)) }})</p>
                            @endif
                            <p class="mt-2 text-gray-700 dark:text-gray-300">{!! nl2br(e($task->description)) !!}</p>
                            @if($task->due_at)
                                <p class="text-sm mt-2 {{ $task->due_at->isPast() ? 'text-red-600 font-bold' : '' }}">
                                    Due: {{ $task->due_at->format('d/m/Y H:i') }}
                                </p>
                            @endif
                        </div>
                        <button wire:click="completeTask({{ $task->id }})" 
                                class="ml-6 bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg">
                            Complete
                        </button>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/task-manager.blade.php

# app/Http/Livewire/PoolTesting.php
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
        'temperature' => null, 'free_chlorine' => null, 'ph' => null,
        'alkalinity' => null, 'calcium_hardness' => null, 'cyanuric_acid' => null, 'notes' => ''
    ];

    public function mount()
    {
        $this->subFacilities = SubFacility::where('facility_id', Auth::user()->profile->current_facility_id)
            ->whereIn('type', ['pool','baby_pool','hot_tub','plunge_pool','turbo_spa'])
            ->get();
        $this->selectedSubFacility = $this->subFacilities->first()?->id;
    }

    public function submit()
    {
        $sub = SubFacility::find($this->selectedSubFacility);
        $rules = $sub->parameter_rules;

        $outOfRange = false;
        $issues = [];

        if ($this->form['temperature'] < $rules['temperature']['min'] ?? 0 || $this->form['temperature'] > $rules['temperature']['max'] ?? 999) {
            $outOfRange = true; $issues[] = "Temperature out of range";
        }
        if ($this->form['free_chlorine'] < $rules['free_chlorine']['min'] ?? 0 || $this->form['free_chlorine'] > $rules['free_chlorine']['max'] ?? 999) {
            $outOfRange = true; $issues[] = "Free Chlorine out of range";
        }
        if ($this->form['ph'] < 7.2 || $this->form['ph'] > 7.6) {
            $outOfRange = true; $issues[] = "pH out of range";
        }

        PoolTest::create([
            'sub_facility_id' => $this->selectedSubFacility,
            'user_id' => Auth::id(),
            'is_out_of_range' => $outOfRange,
            'tested_at' => now(),
        ] + $this->form);

        if ($outOfRange) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->selectedSubFacility,
                'created_by' => Auth::id(),
                'title' => 'URGENT: Pool Test Out of Range – ' . $sub->name,
                'description' => implode("\n", $issues),
                'priority' => 'critical',
                'due_at' => now()->addHours(1)
            ]);
        }

        $this->reset('form');
        session()->flash('message', $outOfRange ? 'Test recorded – CRITICAL TASK CREATED!' : 'Test recorded successfully');
    }

    public function render()
    {
        return view('livewire.pool-testing');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/PoolTesting.php

# resources/views/livewire/pool-testing.blade.php
@'
<div class="max-w-2xl mx-auto">
    <h2 class="text-3xl font-bold mb-8">Pool Water Testing (PWTAG)</h2>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8">
        <div class="mb-6">
            <select wire:model="selectedSubFacility" class="w-full px-4 py-3 rounded-lg border dark:bg-gray-700">
                @foreach($subFacilities as $sub)
                    <option value="{{ $sub->id }}">{{ $sub->name }}</option>
                @endforeach
            </select>
        </div>

        <form wire:submit.prevent="submit" class="space-y-6">
            <div class="grid grid-cols-2 gap-6">
                <x-input label="Temperature (°C)" wire:model="form.temperature" type="number" step="0.1" required />
                <x-input label="Free Chlorine (mg/L)" wire:model="form.free_chlorine" type="number" step="0.1" required />
                <x-input label="pH" wire:model="form.ph" type="number" step="0.01" required />
                <x-input label="Total Alkalinity" wire:model="form.alkalinity" type="number" step="1" />
                <x-input label="Calcium Hardness" wire:model="form.calcium_hardness" type="number" step="1" />
                <x-input label="Cyanuric Acid" wire:model="form.cyanuric_acid" type="number" step="1" />
            </div>

            <x-textarea label="Notes" wire:model="form.notes" rows="3" />

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-lg text-xl">
                Record Test Result
            </button>
        </form>

        @if(session('message'))
            <div class="mt-6 p-6 {{ session('message') includes 'CRITICAL' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }} rounded-lg text-center font-bold">
                {{ session('message') }}
            </div>
        @endif
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/pool-testing.blade.php

Write-Host "06 - Task Manager + Full PWTAG Pool Testing with auto-critical-task creation complete!" -ForegroundColor Green
Write-Host "    Out-of-range results instantly create CRITICAL tasks!" -ForegroundColor Cyan
