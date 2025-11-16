<!-- File: resources/views/external-hire-clubs/index.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>External Hire Clubs for {{ $facility->name }}</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Contact</th>
                <th>Safeguarding</th>
                <th>Notes</th>
                <th>Documents</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($clubs as $club)
                <tr>
                    <td>{{ $club->name }}</td>
                    <td>{{ json_encode($club->contact_details) }}</td>
                    <td>{{ $club->safeguarding_contact }}</td>
                    <td>{{ $club->notes }}</td>
                    <td>
                        @foreach ($club->documents as $doc)
                            <a href="{{ Storage::url($doc->file_path) }}" target="_blank">{{ $doc->type }} ({{ $doc->is_current ? 'Current' : 'Archived' }}) - Exp: {{ $doc->expiry_date }}</a><br>
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
