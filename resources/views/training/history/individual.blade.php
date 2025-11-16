<!-- File: resources/views/training/history/individual.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Training History for {{ $user->name }}</h1>
    <table class="table">
        <!-- Columns: Session Title, Date, Type, Score, Duration -->
        @foreach ($attendances as $att)
            <tr>
                <td>{{ $att->session->title }}</td>
                <td>{{ $att->attended_at }}</td>
                <td>{{ $att->session->type }}</td>
                <td>{{ $att->score ?? 'N/A' }}</td>
                <td>{{ $att->session->duration_hours }}</td>
            </tr>
        @endforeach
    </table>
    <!-- Chart: e.g., <canvas id="scoreChart"></canvas> -->
    <script>
        // Use Chart.js to plot scores over time
        var ctx = document.getElementById('scoreChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [@json($attendances->pluck('attended_at'))],
                datasets: [{
                    label: 'Scores',
                    data: [@json($attendances->pluck('score'))],
                }]
            },
        });
    </script>
@endsection
