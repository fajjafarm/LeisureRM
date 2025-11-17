<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class SubFacility extends Model {
    use SoftDeletes, LogsActivity;
    protected \ = ['facility_id','name','type','is_thermal_suite','check_interval_minutes','last_checked_at','parameters','requires_backwash','max_backwash_days','last_backwash_at'];
    protected \ = ['parameters'=>'array','last_checked_at'=>'datetime','last_backwash_at'=>'datetime'];
    
    public function getParameterRulesAttribute() {
        return match(\->type) {
            'pool','baby_pool' => ['temperature'=>['min'=>26,'max'=>32], 'free_chlorine'=>['min'=>1.0,'max'=>3.0], 'ph'=>['min'=>7.2,'max'=>7.6]],
            'hot_tub','turbo_spa' => ['temperature'=>['min'=>36,'max'=>40], 'free_chlorine'=>['min'=>3.0,'max'=>5.0]],
            'sauna','steam_room' => ['temperature'=>['min'=>70,'max'=>100]],
            default => []
        };
    }
    public function facility() { return \->belongsTo(Facility::class); }
    public function poolTests() { return \->hasMany(PoolTest::class); }
}
