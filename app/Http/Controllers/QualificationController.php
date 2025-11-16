<?php

// File: app/Http/Controllers/QualificationController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\Qualification;
use Illuminate\Http\Request;

class QualificationController extends Controller
{
    public function index()
    {
        $qualifications = Qualification::all();
        return view('qualifications.index', compact('qualifications'));
    }

    public function create()
    {
        return view('qualifications.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        Qualification::create($validated);

        return redirect()->route('qualifications.index');
    }

    // Methods to assign required to ranks
    public function assignRequired(Request $request, Qualification $qualification)
    {
        $validated = $request->validate([
            'rank' => 'required|in:Manager,Deputy Manager,Assistant Manager,Supervisor,Assistant',
            'required' => 'boolean',
        ]);

        $qualification->requiredRanks()->attach($validated['rank'], ['required' => $validated['required'] ?? true]);

        return redirect()->back();
    }

    // Similar for user assignments
}
