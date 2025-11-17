# 08-Livewire-Part3.ps1
Set-Location leisure-facilities-manager

# app/Http/Livewire/SubFacilityCheckTimer.php (20-minute sauna/steam checks, auto-task if missed)
@'
<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class SubFacilityCheckTimer extends Component
{
    public $subFacility;
    public $minutesRemaining;
    public $isOverdue = false;

    protected $listeners = ['refreshCheck' => '$refresh'];

    public function mount($subFacilityId)
    {
        $this->subFacility = SubFacility::findOrFail($subFacilityId);
        $this->calculateTime();
        $this->startPolling();
    }

    public function startPolling()
    {
        $this->dispatchBrowserEvent('start-timer', [
            'interval' => $this->subFacility->check_interval_minutes * 60 * 1000 // ms
        ]);
    }

    public function calculateTime()
    {
        if (!$this->subFacility->last_checked_at) {
            $this->minutesRemaining = $this->subFacility->check_interval_minutes ?? 0;
            $this->isOverdue = true;
            return;
        }

        $nextCheck = $this->subFacility->last_checked_at->addMinutes($this->subFacility->check_interval_minutes);
        $diff = now()->diffInMinutes($nextCheck, false);

        if ($diff < 0) {
            $this->isOverdue = true;
            $this->minutesRemaining = abs($diff);
            $this->createOverdueTask();
        } else {
            $this->minutesRemaining = $diff;
            $this->isOverdue = false;
        }
    }

    public function createOverdueTask()
    {
        if (!Task::where('sub_facility_id', $this->subFacility->id)
                 ->whereNull('completed_at')
                 ->where('title', 'like', '%'.$this->subFacility->name.'%check overdue%')
                 ->exists()) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->subFacility->id,
                'created_by' => Auth::id(),
                'title' => $this->subFacility->name . ' – Routine Check Overdue',
                'description' => "This facility requires checking every {$this->subFacility->check_interval_minutes} minutes.\nLast checked: " . ($this->subFacility->last_checked_at?->format('d/m/Y H:i') ?? 'Never'),
                'priority' => 'high',
                'due_at' => now()->addMinutes(5)
            ]);
        }
    }

    public function markChecked()
    {
        $this->subFacility->update(['last_checked_at' => now()]);
        $this->calculateTime();
        $this->emit('refreshCheck');
        session()->flash('message', $this->subFacility->name . ' checked at ' . now()->format('H:i'));
    }

    public function render()
    {
        $this->calculateTime(); // real-time update
        return view('livewire.sub-facility-check-timer');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/SubFacilityCheckTimer.php

# resources/views/livewire/sub-facility-check-timer.blade.php
@'
<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 text-center">
    <h3 class="text-xl font-bold mb-4">{{ $subFacility->name }}</h3>
    <div class="text-5xl font-mono font-bold {{ $isOverdue ? 'text-red-600' : 'text-green-600' }}">
        {{ str_pad(floor($minutesRemaining / 60), 2, "0", STR_PAD_LEFT) }}:{{ str_pad($minutesRemaining % 60, 2, "0", STR_PAD_LEFT) }}
    </div>
    <p class="mt-2 text-lg">{{ $isOverdue ? 'OVERDUE – Action Required' : 'Until next check' }}</p>
    <button wire:click="markChecked" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded text-xl">
        Check Complete
    </button>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/sub-facility-check-timer.blade.php

# app/Http/Livewire/ChemicalInventory.php (Low stock → auto-task)
@'
<?php

namespace App\Http\Livewire;

use Livewire\Component;
use App\Models\CoshhChemical;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class ChemicalInventory extends Component
{
    public $chemicals;

    public function mount()
    {
        $this->loadChemicals();
    }

    public function loadChemicals()
    {
        $this->chemicals = CoshhChemical::where('business_id', Auth::user()->profile->business_id)
            ->get()
            ->map(function ($chem) {
                $chem->is_low = $chem->current_stock_level <= $chem->min_stock_level;
                if ($chem->is_low && !Task::where('title', 'like', "%{$chem->name}%low stock%")->whereNull('completed_at')->exists()) {
                    Task::create([
                        'business_id' => $chem->business_id,
                        'created_by' => Auth::id(),
                        'title' => "Low Stock: {$chem->name}",
                        'description' => "Current: {$chem->current_stock_level} | Minimum: {$chem->min_stock_level}\nUN: {$chem->un_number}",
                        'priority' => 'high'
                    ]);
                }
                return $chem;
            });
    }

    public function render()
    {
        return view('livewire.chemical-inventory');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/ChemicalInventory.php

# app/Http/Livewire/BackwashTracker.php
@'
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
                    'title' => "Backwash Required – {$this->subFacility->name}"
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
'@ | Out-File -Encoding utf8 app/Http/Livewire/BackwashTracker.php

# Trait for universal PDF/CSV export (add to any Livewire component)
@'
<?php

namespace App\Http\Livewire\Concerns;

use Maatwebsite\Excel\Facades\Excel;
use Barryvdh\DomPDF\Facade\Pdf;

trait ExportsData
{
    public function exportPdf($data, $view, $filename = 'export')
    {
        $pdf = Pdf::loadView($view, ['data' => $data]);
        return response()->streamDownload(function () use ($pdf) {
            echo $pdf->stream();
        }, "{$filename}_" . now()->format('Y-m-d') . '.pdf');
    }

    public function exportCsv($collection, $filename = 'export')
    {
        return Excel::download(new class($collection) extends \Maatwebsite\Excel\Concerns\FromCollection {
            public function __construct($collection) { $this->collection = $collection; }
            public function collection() { return $this->collection; }
        }, "{$filename}_" . now()->format('Y-m-d') . '.csv');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/Concerns/ExportsData.php

Write-Host "08 - Sub-facility timers, chemical low-stock alerts, backwash enforcement & universal PDF/CSV export engine completed"