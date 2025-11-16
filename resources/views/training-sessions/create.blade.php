<!-- File: resources/views/training-sessions/create.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>Create Training Session</h1>
    <form method="POST" action="{{ route('training-sessions.store') }}">
        @csrf
        <div class="form-group">
            <label>Title</label>
            <input type="text" name="title" required class="form-control">
        </div>
        <div class="form-group">
            <label>Date</label>
            <input type="datetime-local" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Type</label>
            <input type="text" name="type" required class="form-control">
        </div>
        <div class="form-group">
            <label>Duration (hours)</label>
            <input type="number" name="duration_hours" step="0.1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Create</button>
    </form>
@endsection
