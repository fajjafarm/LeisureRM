<?php

// File: app/Http/Controllers/PoolTestController.php

namespace App\Http\Controllers;

use App\Models\PoolTest;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PoolTestController extends Controller
{
    public function index(SubFacility $subFacility)
    {
        $tests = $subFacility->poolTests()->latest()->paginate(20);
        return view('pool-tests.index', compact('tests', 'subFacility')); // Blade view
    }

    public function create(SubFacility $subFacility)
    {
        return view('pool-tests.create', compact('subFacility'));
    }

    public function store(Request $request, SubFacility $subFacility)
    {
        $validated = $request->validate([
            'temperature' => 'required|numeric',
            'ph' => 'required|numeric',
            'chlorine' => 'required|numeric',
            'alkalinity' => 'required|numeric',
            'calcium_hardness' => 'required|numeric',
            'tds' => 'nullable|numeric',
        ]);

        $validated['sub_facility_id'] = $subFacility->id;
        $validated['user_id'] = Auth::id();

        PoolTest::create($validated);

        return redirect()->route('pool-tests.index', $subFacility)->with('success', 'Test recorded.');
    }

    // Edit, update, delete similar
}
