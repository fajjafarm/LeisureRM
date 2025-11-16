<!-- File: resources/views/backwash-logs/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Log Backwash for {{ $subFacility->name }}</h1>
    <form method="POST" action="{{ route('backwash-logs.store', $subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Date</label>
            <input type="datetime-local" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Duration (minutes)</label>
            <input type="number" name="duration_minutes" required class="form-control">
        </div>
        <div class="form-group">
            <label>Water Used (e.g., liters)</label>
            <input type="number" name="water_used" step="0.1" required class="form-control">
        </div>
        <div class="form-group">
            <label>Notes</label>
            <textarea name="notes" class="form-control"></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Log Backwash</button>
    </form>
@endsection
