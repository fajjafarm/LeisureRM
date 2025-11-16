<!-- File: resources/views/water-meter-readings/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Water Meter Readings for {{ $subFacility->name }} (Last 30 Days)</h1>

    <!-- Bar Chart -->
    <canvas id="usageChart" width="400" height="200"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var ctx = document.getElementById('usageChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: @json($chartLabels),
                datasets: [{
                    label: 'Daily Usage',
                    data: @json($chartData),
                    backgroundColor: @json($chartData->map(fn($usage) => abs($usage - $normalUsage) > 0 ? 'red' : 'green')),
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
    </script>

    <!-- Table -->
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Reading</th>
                <th>Usage</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($readings as $reading)
                @php
                    $isAbnormal = abs($reading->usage - $normalUsage) > 0; // Adjust tolerance
                    $class = $isAbnormal ? 'table-danger' : 'table-success';
                @endphp
                <tr class="{{ $class }}">
                    <td>{{ $reading->date->format('Y-m-d') }}</td>
                    <td>{{ $reading->reading }}</td>
                    <td>{{ $reading->usage }}</td>
                    <td>{{ $isAbnormal ? 'Abnormal' : 'Normal' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Form to update normal usage -->
    <h2>Update Normal Daily Usage</h2>
    <form method="POST" action="{{ route('water-meter-readings.update-normal', $subFacility) }}">
        @csrf
        @method('PATCH')
        <div class="form-group">
            <label>Normal Daily Usage</label>
            <input type="number" name="normal_daily_usage" value="{{ $normalUsage }}" step="0.1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Update</button>
    </form>
@endsection
