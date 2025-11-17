@extends('layouts.osen')
@section('title', 'Pool Water Tests')
@section('content')
<div class="page-title-box">
    <h4 class="page-title">Pool Water Tests - {{ $subFacility->name ?? 'All' }}</h4>
    <a href="{{ route('pool-tests.create', $subFacility ?? '') }}" class="btn btn-success">+ New Test</a>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-bordered table-hover" id="testsTable">
            <thead class="thead-light">
                <tr>
                    <th>Date & Time</th>
                    <th>Temp (°C)</th>
                    <th>pH</th>
                    <th>Chlorine</th>
                    <th>LSI</th>
                    <th>Status</th>
                    <th>Recorded By</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($poolTests as $test)
                <tr class="{{ $test->saturation_index < -0.3 || $test->saturation_index > 0.3 ? 'table-danger' : 'table-success' }}">
                    <td>{{ $test->created_at->format('d/m/Y H:i') }}</td>
                    <td>{{ $test->temperature }}</td>
                    <td>{{ $test->ph }}</td>
                    <td>{{ $test->chlorine }}</td>
                    <td><strong>{{ $test->saturation_index }}</strong></td>
                    <td>
                        @if($test->saturation_index < -0.3) Corrosive
                        @elseif($test->saturation_index > 0.3) Scaling
                        @else Balanced @endif
                    </td>
                    <td>{{ $test->user->name }}</td>
                    <td>
                        <a href="{{ route('pool-tests.edit', $test) }}" class="btn btn-sm btn-warning">Edit</a>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <div class="mt-3">
            <a href="{{ route('pool-tests.export', ['sub_facility' => $subFacility->id ?? '', 'format' => 'csv']) }}" class="btn btn-success">Export CSV</a>
            <a href="{{ route('pool-tests.export', ['sub_facility' => $subFacility->id ?? '', 'format' => 'pdf']) }}" class="btn btn-danger">Export PDF</a>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>$(document).ready(() => $('#testsTable').DataTable({ order: [[0, 'desc']] }));</script>
@endpush
