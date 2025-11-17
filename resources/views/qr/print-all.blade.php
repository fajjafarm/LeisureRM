<!DOCTYPE html>
<html>
<head>
    <title>Print All QR Codes</title>
    <style>
        .qr-item { float: left; width: 250px; margin: 20px; text-align: center; font-family: Arial; }
        img { width: 200px; height: 200px; }
    </style>
</head>
<body>
    @foreach($subFacilities as $sf)
    <div class="qr-item">
        <h4>{{ $sf->name }}</h4>
        <img src="{{ asset('storage/qr/' . $sf->id . '-pooltest.png') }}" />
        <p>Pool Test</p>
        <img src="{{ asset('storage/qr/' . $sf->id . '-healthcheck.png') }}" />
        <p>Health Check</p>
    </div>
    @endforeach
</body>
</html>
