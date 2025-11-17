<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QrCode extends Model
{
    protected $fillable = ['scannable_type', 'scannable_id', 'url', 'path'];

    public function scannable()
    {
        return $this->morphTo();
    }
}
