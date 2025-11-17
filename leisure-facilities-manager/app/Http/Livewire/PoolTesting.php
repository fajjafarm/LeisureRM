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
                'title' => 'Pool Test Out of Range â€“ Action Required',
                'description' => "Pool: {$sub->name}\nIssues:\nâ€¢ " . implode("\nâ€¢ ", $issues),
                'priority' => 'critical',
                'due_at' => now()->addHours(2)
            ]);
        }

        $this->reset('form');
        session()->flash('message', 'Pool test recorded successfully' . ($outOfRange ? ' â€“ Critical task created' : ''));
    }

    public function render()
    {
        return view('livewire.pool-testing');
    }
}
