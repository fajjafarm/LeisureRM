<!DOCTYPE html>
<html>
<head><title>Print QR Codes</title></head>
<body>
    <h2>{{ $subFacility->name }} - Pool Test</h2>
    <img src="{{ asset('storage/' . $qrPath) }}" />
    <p>Scan to log test</p>
</body>
</html>
