<?php

// File: app/Http/Controllers/TrainingAttendanceController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\TrainingSession;
use App\Models\TrainingAttendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TrainingAttendanceController extends Controller
{
    public function attend(Request $request, TrainingSession $session)
    {
        // Validate token if used
        $validated = $request->validate([
            'score' => 'nullable|numeric|required_if:type,CPR', // Conditional
        ]);

        TrainingAttendance::create([
            'training_session_id' => $session->id,
            'user_id' => Auth::id(),
            'score' => $validated['score'] ?? null,
        ]);

        return redirect()->back()->with('success', 'Attendance recorded.');
    }

    // For charts and tables
    public function individualHistory(User $user)
    {
        $attendances = $user->trainingAttendances()->with('session')->get();
        // Prepare data for table and chart (e.g., scores over time)
        return view('training.history.individual', compact('attendances', 'user'));
    }

    public function teamStats()
    {
        // Monthly averages
        $monthlyData = TrainingAttendance::selectRaw('YEAR(attended_at) as year, MONTH(attended_at) as month, AVG(score) as avg_score, SUM(session.duration_hours) as total_hours')
            ->join('training_sessions as session', 'training_attendances.training_session_id', '=', 'session.id')
            ->groupBy('year', 'month')
            ->get();

        // For charts: Use JSON for Chart.js in view
        return view('training.stats.team', compact('monthlyData'));
    }
}
