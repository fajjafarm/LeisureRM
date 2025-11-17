# 07-TimersCoshhExports.ps1
# # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# app/Http/Livewire/SubFacilityTimer.php (20-minute sauna/steam checks)
@'
<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class SubFacilityTimer extends Component
{
    public $subFacility;
    public $minutesLeft;
    public $isOverdue = false;

    public function mount($subFacilityId)
    {
        $this->subFacility = SubFacility::findOrFail($subFacilityId);
        $this->calculateTime();
    }

    public function calculateTime()
    {
        $interval = $this->subFacility->check_interval_minutes ?? 20;
        $last = $this->subFacility->last_checked_at ?? now()->subMinutes($interval + 1);

        $next = $last->addMinutes($interval);
        $diff = now()->diffInMinutes($next, false);

        if ($diff < 0) {
            $this->isOverdue = true;
            $this->minutesLeft = abs($diff);
            $this->createOverdueTask();
        } else {
            $this->isOverdue = false;
            $this->minutesLeft = $diff;
        }
    }

    public function createOverdueTask()
    {
        if (!Task::where('sub_facility_id', $this->subFacility->id)
                 ->whereNull('completed_at')
                 ->where('title', 'like', '%'.$this->subFacility->name.'%overdue%')
                 ->exists()) {
            Task::create([
                'business_id' => Auth::user()->profile->business_id,
                'facility_id' => Auth::user()->profile->current_facility_id,
                'sub_facility_id' => $this->subFacility->id,
                'created_by' => Auth::id(),
                'title' => $this->subFacility->name . ' – Routine Check Overdue!',
                'description' => "Must be checked every {$this->subFacility->check_interval_minutes} minutes.\nLast checked: " . $this->subFacility->last_checked_at?->format('H:i d/m/Y') ?? 'Never',
                'priority' => 'high',
                'due_at' => now()->addMinutes(5)
            ]);
        }
    }

    public function markChecked()
    {
        $this->subFacility->update(['last_checked_at' => now()]);
        $this->calculateTime();
        session()->flash('message', $this->subFacility->name . ' checked at ' . now()->format('H:i'));
    }

    public function render()
    {
        $this->calculateTime();
        return view('livewire.sub-facility-timer');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/SubFacilityTimer.php

# resources/views/livewire/sub-facility-timer.blade.php
@'
<div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 text-center">
    <h3 class="text-2xl font-bold mb-4">{{ $subFacility->name }}</h3>
    <div class="text-7xl font-mono font-bold {{ $isOverdue ? "text-red-600" : "text-green-600" }}">
        {{ str_pad(floor($minutesLeft / 60), 2, "0", STR_PAD_LEFT) }}:{{ str_pad($minutesLeft % 60, 2, "0", STR_PAD_LEFT) }}
    </div>
    <p class="text-xl mt-4 {{ $isOverdue ? "text-red-600 font-bold" : "" }}">
        {{ $isOverdue ? "OVERDUE – ACTION REQUIRED" : "Until next check" }}
    </p>
    <button wire:click="markChecked" class="mt-8 bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-12 rounded-xl text-xl">
        ✓ Check Complete
    </button>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/sub-facility-timer.blade.php

# app/Http/Livewire/CoshhInventory.php (low-stock auto-tasks)
@'
<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\CoshhChemical;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class CoshhInventory extends Component
{
    public $chemicals;

    public function mount()
    {
        $this->loadChemicals();
    }

    public function loadChemicals()
    {
        $this->chemicals = CoshhChemical::where('business_id', Auth::user()->profile->business_id)->get();

        foreach ($this->chemicals as $chem) {
            if ($chem->current_stock_level <= $chem->min_stock_level) {
                if (!Task::where('title', 'like', "%{$chem->name}%low stock%")->whereNull('completed_at')->exists()) {
                    Task::create([
                        'business_id' => $chem->business_id,
                        'created_by' => Auth::id(),
                        'title' => "LOW STOCK: {$chem->name}",
                        'description' => "Current: {$chem->current_stock_level} | Minimum: {$chem->min_stock_level}\nUN: {$chem->un_number}",
                        'priority' => 'high'
                    ]);
                }
            }
        }
    }

    public function render()
    {
        return view('livewire.coshh-inventory');
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/CoshhInventory.php

# resources/views/livewire/coshh-inventory.blade.php (simplified)
@'
<div>
    <h2 class="text-3xl font-bold mb-6">COSHH Inventory</h2>
    <div class="grid gap-6">
        @foreach($chemicals as $chem)
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 {{ $chem->current_stock_level <= $chem->min_stock_level ? "border-l-8 border-red-600" : "" }}">
                <h3 class="text-xl font-bold">{{ $chem->name }}</h3>
                <p>Stock: <strong class="{{ $chem->current_stock_level <= $chem->min_stock_level ? "text-red-600" : "text-green-600" }}">{{ $chem->current_stock_level }}</strong> / {{ $chem->min_stock_level }} minimum</p>
                @if($chem->un_number)<p class="text-sm">UN: {{ $chem->un_number }}</p>@endif
            </div>
        @endforeach
    </div>
</div>
'@ | Out-File -Encoding utf8 resources/views/livewire/coshh-inventory.blade.php

# Trait for PDF/CSV exports (add to any component)
@'
<?php
namespace App\Http\Livewire\Concerns;
use Maatwebsite\Excel\Facades\Excel;
use Barryvdh\DomPDF\Facade\Pdf;

trait ExportsData
{
    public function exportPdf($data, $view, $filename = "report")
    {
        $pdf = Pdf::loadView($view, ["data" => $data]);
        return response()->streamDownload(fn() => print($pdf->output()), "$filename.pdf");
    }

    public function exportCsv($collection, $filename = "export")
    {
        return Excel::download(new class($collection) extends \Illuminate\Support\Collection implements \Maatwebsite\Excel\Concerns\FromCollection {
            public function __construct($c) { $this->items = $c; }
            public function collection() { return $this->items; }
        }, "$filename.csv");
    }
}
'@ | Out-File -Encoding utf8 app/Http/Livewire/Concerns/ExportsData.php

Write-Host "07 - 20-minute sauna timer + COSHH low-stock alerts + PDF/CSV export trait complete!" -ForegroundColor Green
Write-Host "    Overdue checks and low stock now create tasks automatically!" -ForegroundColor Cyan
