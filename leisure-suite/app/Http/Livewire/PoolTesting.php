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
                'title' => 'URGENT: Pool Test Out of Range â€“ ' . $sub->name,
                'description' => implode("\n", $issues),
                'priority' => 'critical',
                'due_at' => now()->addHours(1)
            ]);
        }

        $this->reset('form');
        session()->flash('message', $outOfRange ? 'Test recorded â€“ CRITICAL TASK CREATED!' : 'Test recorded successfully');
    }

    public function render()
    {
        return view('livewire.pool-testing');
    }
}
