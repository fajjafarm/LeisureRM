<!-- File: resources/views/training-sessions/show.blade.php (For QR) -->

@extends('admin.layout')

@section('content')
    <h1>{{ $session->title }}</h1>
    {!! $session->qr_code !!} <!-- Display SVG QR -->
@endsection
