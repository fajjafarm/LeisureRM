<?php

// File: app/Models/AnnualInspectionRecord.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnnualInspectionRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'annual_inspection_item_id',
        'date',
        'inspector_name',
        'details',
        'certificate_file',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function item()
    {
        return $this->belongsTo(AnnualInspectionItem::class);
    }
}
