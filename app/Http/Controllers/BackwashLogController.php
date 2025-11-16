<?php

// File: app/Http/Controllers/BackwashLogController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\BackwashLog;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Carbon;

class BackwashLogController extends Controller
{
    public function index(SubFacility $subFacility)
    {
        $logs = $subFacility->backwashLogs()->latest()->paginate(20);
        $lastBackwash = $subFacility->backwashLogs()->latest()->first();
        $isOverdue = $lastBackwash ? Carbon::now()->diffInDays($lastBackwash->date) > $subFacility->backwash_interval_days : true;

        if ($isOverdue) {
            $this->createOverdueTask($subFacility);
        }

        // Chart data: frequency over time (e.g., monthly backwashes)
        $chartData = $logs->groupBy(function ($log) {
            return $log->date->format('Y-m');
        })->map->count();

        return view('backwash-logs.index', compact('logs', 'subFacility', 'isOverdue', 'chartData'));
    }

    public function create(SubFacility $subFacility)
    {
        return view('backwash-logs.create', compact('subFacility'));
    }

    public function store(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'duration_minutes' => 'required|integer',
            'water_used' => 'required|numeric',
            'notes' => 'nullable|string',
        ]);

        $validated['sub_facility_id'] = $subFacility->id;
        $validated['user_id'] = Auth::id();

        BackwashLog::create($validated);

        // Optional: Link to water usage if integrated

        return redirect()->route('backwash-logs.index', $subFacility)->with('success', 'Backwash logged.');
    }

    private function createOverdueTask(SubFacility $subFacility)
    {
        $existing = Task::where('title', 'like', "%Overdue Backwash for {$subFacility->name}%")->where('status', 'Pending')->first();
        if ($existing) return;

        Task::create([
            'title' => "Overdue Backwash for {$subFacility->name}",
            'description' => "Last backwash was more than {$subFacility->backwash_interval_days} days ago. Please perform backwash.",
            'priority' => 'Medium',
            'assigned_to_rank' => 'Supervisor',
            'status' => 'Pending',
            'assigner_id' => Auth::id() ?? 1,
        ]);
    }

    // Update interval
    public function updateInterval(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'backwash_interval_days' => 'required|integer|min:1',
        ]);

        $subFacility->update($validated);

        return redirect()->back()->with('success', 'Backwash interval updated.');
    }
}
