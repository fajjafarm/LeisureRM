<?php

// File: app/Http/Controllers/ChemicalStockController.php

namespace App\Http\Controllers;

use App\Models\ChemicalStock;
use Illuminate\Http\Request;

class ChemicalStockController extends Controller
{
    public function index()
    {
        $stocks = ChemicalStock::paginate(20);
        return view('chemical-stocks.index', compact('stocks'));
    }

    public function create()
    {
        return view('chemical-stocks.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'sub_facility_id' => 'nullable|exists:sub_facilities,id',
            'chemical_name' => 'required|string',
            'quantity' => 'required|numeric',
            'unit' => 'required|string',
            'min_threshold' => 'required|numeric',
        ]);

        ChemicalStock::create($validated);

        return redirect()->route('chemical-stocks.index');
    }

    // Update for adding/subtracting quantity, etc.
}
