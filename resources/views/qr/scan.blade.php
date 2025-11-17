@extends('layouts.app')
@section('content')
<div class="container">
    <h1 class="mt-5">{{ $subFacility->name }}</h1>
    <div class="row mt-4">
        <div class="col-md-4"><a href="{{ route('pool-tests.create', $subFacility) }}" class="btn btn-primary btn-lg btn-block">Record Pool Test</a></div>
        <div class="col-md-4"><a href="{{ route('health-checks.create', $subFacility) }}" class="btn btn-success btn-lg btn-block">Health Check</a></div>
        <div class="col-md-4"><a href="{{ route('chemical-stocks.create', $subFacility) }}" class="btn btn-info btn-lg btn-block">Chemical Stock</a></div>
    </div>
</div>
@endsection
