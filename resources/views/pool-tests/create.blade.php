@extends('layouts.osen')
@section('title', 'Record Pool Test')
@section('content')
<div class="card">
    <div class="card-body">
        <h4>Record Pool Test - {{ $subFacility->name }}</h4>
        <form action="{{ route('pool-tests.store') }}" method="POST">
            @csrf
            <input type="hidden" name="sub_facility_id" value="{{ $subFacility->id }}">
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Temperature (°C)</label>
                        <input type="number" step="0.1" name="temperature" class="form-control" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>pH</label>
                        <input type="number" step="0.01" name="ph" min="6.8" max="8.2" class="form-control" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Free Chlorine (ppm)</label>
                        <input type="number" step="0.1" name="chlorine" class="form-control" required>
                    </div>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Save Test</button>
        </form>
    </div>
</div>
@endsection
