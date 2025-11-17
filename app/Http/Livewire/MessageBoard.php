<?php
namespace App\Http\Livewire;
use Livewire\Component;
use App\Models\MessageBoardPost;
use App\Models\DailyOverview;
use Illuminate\Support\Facades\Auth;

class MessageBoard extends Component
{
    public $message = '';
    public $posts;
    public $overview;
    public $staffOnShift = [];
    public $newStaffName = '';
    public $shiftStart = '';
    public $shiftEnd = '';

    public function mount()
    {
        $this->loadData();
    }

    public function loadData()
    {
        $facilityId = Auth::user()->profile->current_facility_id;
        $this->posts = MessageBoardPost::where('facility_id', $facilityId)->latest()->get();

        $this->overview = DailyOverview::firstOrCreate(
            ['facility_id' => $facilityId, 'overview_date' => today()],
            ['expected_guests' => 0, 'staff_on_shift' => []]
        );

        $this->staffOnShift = $this->overview->staff_on_shift ?? [];
    }

    public function postMessage()
    {
        $this->validate(['message' => 'required|string|max:1000']);
        MessageBoardPost::create([
            'facility_id' => Auth::user()->profile->current_facility_id,
            'user_id' => Auth::id(),
            'message' => $this->message
        ]);
        $this->message = '';
        $this->loadData();
    }

    public function addShift()
    {
        $this->validate([
            'newStaffName' => 'required',
            'shiftStart' => 'required',
            'shiftEnd' => 'required'
        ]);

        $shift = $this->overview->staff_on_shift ?? [];
        $shift[] = ['name' => $this->newStaffName, 'start' => $this->shiftStart, 'end' => $this->shiftEnd];
        $this->overview->update(['staff_on_shift' => $shift]);

        $this->reset(['newStaffName','shiftStart','shiftEnd']);
        $this->loadData();
    }

    public function render()
    {
        return view('livewire.message-board');
    }
}
