<!-- File: resources/views/water-meter-readings/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Record Water Meter Reading for {{ $subFacility->name }}</h1>
    <form method="POST" action="{{ route('water-meter-readings.store', $subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Date</label>
            <input type="date" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Reading</label>
            <input type="number" name="reading" step="0.01" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
@endsection
