<?php

namespace App\Http\Controllers;

use chillerlan\QRCode\QRCode;
use App\Models\SubFacility;

class QrCodeController extends Controller
{
    public function generate(SubFacility $subFacility)
    {
        $url = route('qr.scan', ['type' => 'pool-test', 'id' => $subFacility->id]);
        $qr = new QRCode();
        $qrPath = 'qr/' . $subFacility->id . '-pooltest.png';
        $qr->render($url, storage_path('app/public/' . $qrPath));

        return view('qr.print', compact('subFacility', 'qrPath'));
    }

    public function scan($type, $id)
    {
        $url = match($type) {
            'pool-test' => route('pool-tests.create', ['sub_facility_id' => $id]),
            'health-check' => route('health-checks.create', ['sub_facility_id' => $id]),
            default => route('dashboard')
        };

        return redirect($url);
    }
}
