<!-- File: resources/views/annual-inspection-items/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Add Annual Inspection Item</h1>
    <form method="POST" action="{{ route('annual-inspection-items.store') }}" enctype="multipart/form-data">
        @csrf
        <div class="form-group">
            <label>Name</label>
            <input type="text" name="name" required class="form-control">
        </div>
        <div class="form-group">
            <label>Description</label>
            <textarea name="description" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Interval (years)</label>
            <input type="number" name="inspection_interval_years" value="1" min="1" required class="form-control">
        </div>
        <!-- Optional initial record -->
        <h2>Initial Record</h2>
        <div class="form-group">
            <label>Date</label>
            <input type="date" name="date" class="form-control">
        </div>
        <div class="form-group">
            <label>Inspector Name</label>
            <input type="text" name="inspector_name" class="form-control">
        </div>
        <div class="form-group">
            <label>Details</label>
            <textarea name="details" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Certificate</label>
            <input type="file" name="certificate_file">
        </div>
        <button type="submit" class="btn btn-primary">Add</button>
    </form>
@endsection
