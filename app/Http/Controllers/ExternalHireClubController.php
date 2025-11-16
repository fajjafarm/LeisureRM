<?php

// File: app/Http/Controllers/ExternalHireClubController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\ExternalHireClub;
use App\Models\Facility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ExternalHireClubController extends Controller
{
    public function index(Facility $facility)
    {
        $clubs = $facility->externalHireClubs()->paginate(20);
        return view('external-hire-clubs.index', compact('clubs', 'facility'));
    }

    public function create(Facility $facility)
    {
        return view('external-hire-clubs.create', compact('facility'));
    }

    public function store(Request $request, Facility $facility)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'contact_details' => 'nullable|json',
            'safeguarding_contact' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $validated['facility_id'] = $facility->id;

        $club = ExternalHireClub::create($validated);

        // Handle document uploads
        $this->handleDocuments($request, $club);

        return redirect()->route('external-hire-clubs.index', $facility)->with('success', 'Club added.');
    }

    public function update(Request $request, ExternalHireClub $club)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'contact_details' => 'nullable|json',
            'safeguarding_contact' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $club->update($validated);

        // Handle new documents (archive old if replacing)
        if ($request->hasFile('qualifications') || $request->hasFile('insurance')) {
            $club->documents()->update(['is_current' => false]); // Archive old
            $this->handleDocuments($request, $club);
        }

        return redirect()->back()->with('success', 'Club updated.');
    }

    private function handleDocuments(Request $request, ExternalHireClub $club)
    {
        if ($request->hasFile('qualifications')) {
            foreach ($request->file('qualifications') as $file) {
                $path = $file->store('documents/qualifications');
                $club->documents()->create([
                    'type' => 'qualification',
                    'file_path' => $path,
                    'expiry_date' => $request->input('qual_expiry'), // Assume input
                    'is_current' => true,
                ]);
            }
        }

        if ($request->hasFile('insurance')) {
            $path = $request->file('insurance')->store('documents/insurance');
            $club->documents()->create([
                'type' => 'insurance',
                'file_path' => $path,
                'expiry_date' => $request->input('ins_expiry'),
                'is_current' => true,
            ]);
        }
    }

    // View historical documents in index or show view
}
