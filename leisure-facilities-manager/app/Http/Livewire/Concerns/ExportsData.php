<?php

namespace App\Http\Livewire\Concerns;

use Maatwebsite\Excel\Facades\Excel;
use Barryvdh\DomPDF\Facade\Pdf;

trait ExportsData
{
    public function exportPdf($data, $view, $filename = 'export')
    {
        $pdf = Pdf::loadView($view, ['data' => $data]);
        return response()->streamDownload(function () use ($pdf) {
            echo $pdf->stream();
        }, "{$filename}_" . now()->format('Y-m-d') . '.pdf');
    }

    public function exportCsv($collection, $filename = 'export')
    {
        return Excel::download(new class($collection) extends \Maatwebsite\Excel\Concerns\FromCollection {
            public function __construct($collection) { $this->collection = $collection; }
            public function collection() { return $this->collection; }
        }, "{$filename}_" . now()->format('Y-m-d') . '.csv');
    }
}
