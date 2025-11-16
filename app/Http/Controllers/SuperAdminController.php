<?php

// File: app/Http/Controllers/SuperAdminController.php

namespace App\Http\Controllers;

use App\Models\Business;
use App\Models\Facility;
use App\Models\SubFacility;
use App\Models\User;
use Illuminate\Http\Request;

class SuperAdminController extends Controller
{
    public function __construct()
    {
        $this->middleware('role:SuperAdmin');
    }

    public function dashboard()
    {
        // Extend Osen dashboard
        return view('admin.dashboard'); // Assume Osen view
    }

    public function createBusiness(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        Business::create($validated);

        return redirect()->back()->with('success', 'Business created.');
    }

    // Similar methods for edit, delete

    public function assignFacilities(Request $request)
    {
        $validated = $request->validate([
            'business_id' => 'required|exists:businesses,id',
            'facility_ids' => 'array|exists:facilities,id',
        ]);

        $business = Business::find($validated['business_id']);
        $business->facilities()->sync($validated['facility_ids'] ?? []);

        return redirect()->back();
    }

    // Methods for SubFacilities, assignments, settings, etc.
}
