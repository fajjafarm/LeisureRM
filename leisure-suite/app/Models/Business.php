<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Business extends Model {
    use SoftDeletes, LogsActivity;
    protected \ = ['name','slug','contact_email','phone','address','settings','is_active'];
    protected \ = ['settings'=>'array','is_active'=>'boolean'];
    public function getActivitylogOptions(): LogOptions { return LogOptions::defaults()->logFillable(); }
    public function facilities() { return \->hasMany(Facility::class); }
    public function coshhChemicals() { return \->hasMany(CoshhChemical::class); }
}
