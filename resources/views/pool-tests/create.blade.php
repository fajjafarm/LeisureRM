<!-- File: resources/views/pool-tests/create.blade.php -->

@extends('admin.layout') <!-- Assume Osen layout -->

@section('content')
    <h1>Record Pool Test for {{ $subFacility->name }}</h1>
    <form method="POST" action="{{ route('pool-tests.store', $subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Temperature</label>
            <input type="number" name="temperature" step="0.1" required class="form-control">
        </div>
        <div class="form-group">
            <label>pH</label>
            <input type="number" name="ph" step="0.1" required class="form-control">
        </div>
        <!-- Similar for other fields -->
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
@endsection
