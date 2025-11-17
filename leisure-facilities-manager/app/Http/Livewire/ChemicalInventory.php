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
