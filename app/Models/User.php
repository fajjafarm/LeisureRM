<?php
namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Spatie\Permission\Traits\HasRoles;
use Spatie\Activitylog\Traits\LogsActivity;

class User extends Authenticatable {
    use HasRoles, LogsActivity;
    protected \ = ['name','email','password'];
    protected \ = ['password','remember_token'];
    public function profile() { return \->hasOne(UserProfile::class); }
    public function currentFacility() { return \->profile?->currentFacility; }
}

class UserProfile extends \Illuminate\Database\Eloquent\Model {
    protected \ = ['user_id','business_id','current_facility_id','start_date','end_date','required_training_hours_per_month','training_hours_this_month'];
    public function user() { return \->belongsTo(User::class); }
    public function business() { return \->belongsTo(Business::class); }
    public function currentFacility() { return \->belongsTo(Facility::class, 'current_facility_id'); }
}
