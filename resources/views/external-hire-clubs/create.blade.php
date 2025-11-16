<!-- File: resources/views/external-hire-clubs/create.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>Add External Hire Club</h1>
    <form method="POST" action="{{ route('external-hire-clubs.store', $facility) }}" enctype="multipart/form-data">
        @csrf
        <div class="form-group">
            <label>Name</label>
            <input type="text" name="name" required class="form-control">
        </div>
        <div class="form-group">
            <label>Contact Details (JSON)</label>
            <textarea name="contact_details" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Safeguarding Contact</label>
            <input type="text" name="safeguarding_contact" class="form-control">
        </div>
        <div class="form-group">
            <label>Notes</label>
            <textarea name="notes" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Qualifications (multiple)</label>
            <input type="file" name="qualifications[]" multiple>
            <label>Expiry</label>
            <input type="date" name="qual_expiry">
        </div>
        <div class="form-group">
            <label>Insurance</label>
            <input type="file" name="insurance">
            <label>Expiry</label>
            <input type="date" name="ins_expiry">
        </div>
        <button type="submit" class="btn btn-primary">Add</button>
    </form>
@endsection
