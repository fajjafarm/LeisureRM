@extends('layouts.osen')

@section('content')
<div class="container-fluid">
    <h2>Pool Water Tests</h2>

    <div class="card">
        <div class="card-body">
            <a href="{{ route('pool-tests.create') }}" class="btn btn-primary mb-3">New Test</a>

            <table class="table table-bordered" id="poolTestsTable">
                <thead>
                    <tr>
                        <th>Date</th><th>Temp</th><th>pH</th><th>Chlorine</th><th>LSI</th><th>Recorder</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($poolTests as $test)
                    <tr class="{{ $test->saturation_index < -0.3 || $test->saturation_index > 0.3 ? 'table-danger' : '' }}">
                        <td>{{ $test->created_at->format('d/m/Y H:i') }}</td>
                        <td>{{ $test->temperature }}°C</td>
                        <td>{{ $test->ph }}</td>
                        <td>{{ $test->chlorine }}</td>
                        <td>{{ $test->saturation_index }}</td>
                        <td>{{ $test->user->name }}</td>
                        <td>
                            <a href="{{ route('pool-tests.edit', $test) }}" class="btn btn-sm btn-warning">Edit</a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>

            <div class="mt-3">
                <a href="{{ route('pool-tests.export', 'csv') }}" class="btn btn-success">Export CSV</a>
                <a href="{{ route('pool-tests.export', 'pdf') }}" class="btn btn-danger">Export PDF</a>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    $(document).ready(function() {
        $('#poolTestsTable').DataTable();
    });
</script>
@endpush
