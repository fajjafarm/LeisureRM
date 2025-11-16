<!-- File: resources/views/annual-inspection-items/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Annual Inspection Items</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Interval (years)</th>
                <th>Last Inspection</th>
                <th>Records</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($items as $item)
                <tr>
                    <td>{{ $item->name }}</td>
                    <td>{{ $item->description }}</td>
                    <td>{{ $item->inspection_interval_years }}</td>
                    <td>{{ $item->lastRecord()?->date }}</td>
                    <td>
                        @foreach ($item->records as $rec)
                            <a href="{{ Storage::url($rec->certificate_file) }}" target="_blank">Record {{ $rec->date }} by {{ $rec->inspector_name }}</a><br>
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
