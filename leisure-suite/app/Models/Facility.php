<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Facility extends Model {
    use SoftDeletes, LogsActivity;
    protected \ = ['business_id','name','slug','address','postcode','is_active'];
    public function business() { return \->belongsTo(Business::class); }
    public function subFacilities() { return \->hasMany(SubFacility::class); }
}
