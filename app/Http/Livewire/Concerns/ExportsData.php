<?php
namespace App\Http\Livewire\Concerns;
use Maatwebsite\Excel\Facades\Excel;
use Barryvdh\DomPDF\Facade\Pdf;

trait ExportsData
{
    public function exportPdf($data, $view, $filename = "report")
    {
        $pdf = Pdf::loadView($view, ["data" => $data]);
        return response()->streamDownload(fn() => print($pdf->output()), "$filename.pdf");
    }

    public function exportCsv($collection, $filename = "export")
    {
        return Excel::download(new class($collection) extends \Illuminate\Support\Collection implements \Maatwebsite\Excel\Concerns\FromCollection {
            public function __construct($c) { $this->items = $c; }
            public function collection() { return $this->items; }
        }, "$filename.csv");
    }
}
