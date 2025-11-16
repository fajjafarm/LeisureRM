<!-- File: resources/views/qualifications/index.blade.php (Example View) -->

@extends('admin.layout')

@section('content')
    <h1>Qualifications</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Required for Ranks</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($qualifications as $qual)
                <tr>
                    <td>{{ $qual->name }}</td>
                    <td>{{ $qual->description }}</td>
                    <td>
                        @foreach ($qual->requiredRanks as $rank => $pivot)
                            {{ $rank }}: {{ $pivot->required ? 'Yes' : 'No' }}
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
