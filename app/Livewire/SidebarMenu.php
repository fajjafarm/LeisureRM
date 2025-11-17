<?php

namespace App\Livewire;

use Livewire\Component;
use App\Models\SubFacility;
use Carbon\Carbon;

class SidebarMenu extends Component
{
    public $overdue = [];

    public function mount()
    {
        $this->checkOverdue();
    }

    public function checkOverdue()
    {
        $this->overdue = SubFacility::with('healthChecks')->get()->filter(function ($sf) {
            if (!$sf->healthChecks->count()) return true;
            $last = $sf->healthChecks->sortByDesc('created_at')->first();
            $minutes = Carbon::now()->diffInMinutes($last->created_at);
            return $minutes > $sf->check_interval_minutes;
        })->pluck('id')->toArray();
    }

    public function render()
    {
        return view('livewire.sidebar-menu');
    }
}
