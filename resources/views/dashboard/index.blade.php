@extends('layouts.osen')
@section('title', 'Dashboard')
@section('content')
<div class="row">
    <div class="col-xl-3 col-md-6">
        <div class="card-box">
            <h4 class="header-title">Overdue Checks</h4>
            <h2 class="text-danger">{{ App\Models\HealthCheck::overdueCount() }}</h2>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card-box">
            <h4 class="header-title">Low Chemical Stock</h4>
            <h2 class="text-warning">{{ App\Models\ChemicalStock::lowStock()->count() }}</h2>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body">
                <h4>Recent Pool Tests</h4>
                <livewire:pool-test-chart />
            </div>
        </div>
    </div>
</div>
@endsection
