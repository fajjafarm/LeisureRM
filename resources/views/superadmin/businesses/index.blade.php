@extends('layouts.osen')
@section('title', 'Businesses')
@section('content')
<div class="page-title-box">
    <h3>Businesses</h3>
    <a href="{{ route('superadmin.businesses.create') }}" class="btn btn-primary">+ Add Business</a>
</div>
<table class="table table-striped">
    <thead><tr><th>Name</th><th>Facilities</th><th>Actions</th></tr></thead>
    <tbody>
        @foreach($businesses as $b)
        <tr>
            <td>{{ $b->name }}</td>
            <td>{{ $b->facilities->count() }}</td>
            <td>
                <a href="{{ route('superadmin.facilities.index', $b) }}" class="btn btn-sm btn-info">Facilities</a>
            </td>
        </tr>
        @endforeach
    </tbody>
</table>
@endsection
