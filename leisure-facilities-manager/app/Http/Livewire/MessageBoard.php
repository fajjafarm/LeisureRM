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
