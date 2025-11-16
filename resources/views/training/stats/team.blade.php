<!-- File: resources/views/training/stats/team.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Team Training Stats</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Month</th>
                <th>Avg Score</th>
                <th>Total Hours</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($monthlyData as $data)
                <tr>
                    <td>{{ $data->year }}-{{ $data->month }}</td>
                    <td>{{ $data->avg_score }}</td>
                    <td>{{ $data->total_hours }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    <!-- Charts similar to above, bar for monthly avg, etc. -->
@endsection
