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
