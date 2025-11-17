@extends('layouts.osen')
@section('title', 'Health & Safety Check')
@section('content')
<div class="card">
    <div class="card-body">
        <h4>Health Suite Check - {{ $subFacility->name }}</h4>
        <form action="{{ route('health-checks.store') }}" method="POST">
            @csrf
            <input type="hidden" name="sub_facility_id" value="{{ $subFacility->id }}">
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control" required>
                    <option>Passed</option>
                    <option>Failed</option>
                    <option>Maintenance Required</option>
                </select>
            </div>
            <div class="form-group">
                <label>Notes</label>
                <textarea name="notes" class="form-control" rows="5"></textarea>
            </div>
            <button type="submit" class="btn btn-success btn-primary">Submit Check</button>
        </form>
    </div>
</div>
@endsection
