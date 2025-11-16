<!-- File: resources/views/backwash-logs/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Backwash Logs for {{ $subFacility->name }}</h1>
    @if ($isOverdue)
        <div class="alert alert-warning">Backwash is overdue!</div>
    @endif

    <!-- Chart: Bar for monthly frequency -->
    <canvas id="backwashChart" width="400" height="200"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var ctx = document.getElementById('backwashChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: @json($chartData->keys()),
                datasets: [{
                    label: 'Backwashes per Month',
                    data: @json($chartData->values()),
                    backgroundColor: 'blue',
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true, stepSize: 1 }
                }
            }
        });
    </script>

    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Duration (min)</th>
                <th>Water Used</th>
                <th>Notes</th>
                <th>User</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($logs as $log)
                <tr>
                    <td>{{ $log->date }}</td>
                    <td>{{ $log->duration_minutes }}</td>
                    <td>{{ $log->water_used }}</td>
                    <td>{{ $log->notes }}</td>
                    <td>{{ $log->user->name }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    {{ $logs->links() }}

    <!-- Form to update interval -->
    <h2>Update Backwash Interval</h2>
    <form method="POST" action="{{ route('backwash-logs.update-interval', $subFacility) }}">
        @csrf
        @method('PATCH')
        <div class="form-group">
            <label>Interval (days)</label>
            <input type="number" name="backwash_interval_days" value="{{ $subFacility->backwash_interval_days }}" min="1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Update</button>
    </form>
@endsection
