<?php

// File: app/Http/Controllers/HealthCheckController.php

namespace App\Http\Controllers;

use App\Models\HealthCheck;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HealthCheckController extends Controller
{
    public function index(SubFacility $subFacility)
    {
        $checks = $subFacility->healthChecks()->latest()->paginate(20);
        return view('health-checks.index', compact('checks', 'subFacility'));
    }

    public function store(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'notes' => 'nullable|string',
            'status' => 'required|in:Passed,Failed,Maintenance',
        ]);

        $validated['sub_facility_id'] = $subFacility->id;
        $validated['user_id'] = Auth::id();

        HealthCheck::create($validated);

        return redirect()->back()->with('success', 'Check recorded.');
    }
}
