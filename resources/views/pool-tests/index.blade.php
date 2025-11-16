<!-- File: resources/views/pool-tests/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Pool Tests for {{ $subFacility->name }}</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Temperature</th>
                <th>pH</th>
                <!-- Other columns -->
                <th>Balance Result</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($tests as $test)
                <tr>
                    <td>{{ $test->tested_at }}</td>
                    <td>{{ $test->temperature }}</td>
                    <td>{{ $test->ph }}</td>
                    <!-- Others -->
                    <td>{{ $test->balance_result }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    {{ $tests->links() }}
@endsection
