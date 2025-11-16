<?php

// File: app/Http/Controllers/TrainingSessionController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\TrainingSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TrainingSessionController extends Controller
{
    // Restrict to managers, etc., via middleware or gates

    public function index()
    {
        $sessions = TrainingSession::latest()->paginate(20);
        return view('training-sessions.index', compact('sessions'));
    }

    public function create()
    {
        return view('training-sessions.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'date' => 'required|date',
            'type' => 'required|string',
            'duration_hours' => 'required|numeric',
        ]);

        $validated['created_by'] = Auth::id();

        $session = TrainingSession::create($validated);
        $session->generateQrCode();

        return redirect()->route('training-sessions.index');
    }

    // Show QR code in view
}
