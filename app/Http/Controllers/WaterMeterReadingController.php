<?php

// File: app/Http/Controllers/WaterMeterReadingController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\SubFacility;
use App\Models\WaterMeterReading;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;

class WaterMeterReadingController extends Controller
{
    public function index(SubFacility $subFacility)
    {
        $readings = $subFacility->waterMeterReadings()
            ->where('date', '>=', Carbon::now()->subDays(30))
            ->orderBy('date', 'desc')
            ->get();

        $normalUsage = $subFacility->normal_daily_usage;

        // Prepare chart data
        $chartLabels = $readings->pluck('date')->map(fn($date) => $date->format('Y-m-d'));
        $chartData = $readings->pluck('usage');

        // Check for abnormal and create tasks
        foreach ($readings as $reading) {
            if ($reading->isAbnormal($normalUsage)) {
                $this->createAbnormalUsageTask($reading);
            }
        }

        return view('water-meter-readings.index', compact('readings', 'subFacility', 'normalUsage', 'chartLabels', 'chartData'));
    }

    public function create(SubFacility $subFacility)
    {
        return view('water-meter-readings.create', compact('subFacility'));
    }

    public function store(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'reading' => 'required|numeric',
        ]);

        $validated['sub_facility_id'] = $subFacility->id;

        $reading = WaterMeterReading::create($validated);

        $normalUsage = $subFacility->normal_daily_usage;
        if ($reading->isAbnormal($normalUsage)) {
            $this->createAbnormalUsageTask($reading);
        }

        return redirect()->route('water-meter-readings.index', $subFacility)->with('success', 'Reading recorded.');
    }

    private function createAbnormalUsageTask(WaterMeterReading $reading)
    {
        // Check if task already exists for this
        $existing = Task::where('title', 'like', "%Water Usage Check for {$reading->date}%")->first();
        if ($existing) return;

        Task::create([
            'title' => "Abnormal Water Usage Check for {$reading->date}",
            'description' => "Usage: {$reading->usage}. Normal: {$reading->subFacility->normal_daily_usage}. Please investigate.",
            'priority' => 'High',
            'assigned_to_rank' => 'Supervisor', // Or higher; can assign to multiple if needed
            'status' => 'Pending',
            'assigner_id' => Auth::id() ?? 1, // System or current user
        ]);
    }

    // Update normal usage
    public function updateNormalUsage(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'normal_daily_usage' => 'required|numeric',
        ]);

        $subFacility->update($validated);

        return redirect()->back()->with('success', 'Normal usage updated.');
    }
}
