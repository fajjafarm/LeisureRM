<?php

// File: app/Http/Controllers/AnnualInspectionItemController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\AnnualInspectionItem;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AnnualInspectionItemController extends Controller
{
    public function index(SubFacility $subFacility = null)
    {
        $items = $subFacility ? $subFacility->annualInspectionItems()->paginate(20) : AnnualInspectionItem::paginate(20);
        return view('annual-inspection-items.index', compact('items', 'subFacility'));
    }

    public function create(SubFacility $subFacility = null)
    {
        return view('annual-inspection-items.create', compact('subFacility'));
    }

    public function store(Request $request, SubFacility $subFacility = null)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'inspection_interval_years' => 'integer|min:1',
        ]);

        if ($subFacility) {
            $validated['sub_facility_id'] = $subFacility->id;
        }

        $item = AnnualInspectionItem::create($validated);

        // Handle initial record if provided
        $this->handleRecord($request, $item);

        return redirect()->route('annual-inspection-items.index', $subFacility)->with('success', 'Item added.');
    }

    public function addRecord(Request $request, AnnualInspectionItem $item)
    {
        $this->handleRecord($request, $item);
        return redirect()->back()->with('success', 'Record added.');
    }

    private function handleRecord(Request $request, AnnualInspectionItem $item)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'inspector_name' => 'required|string',
            'details' => 'nullable|string',
            'certificate_file' => 'nullable|file|mimes:pdf,jpg,png',
        ]);

        if ($request->hasFile('certificate_file')) {
            $validated['certificate_file'] = $request->file('certificate_file')->store('inspections/certificates');
        }

        $item->records()->create($validated);
    }
}
