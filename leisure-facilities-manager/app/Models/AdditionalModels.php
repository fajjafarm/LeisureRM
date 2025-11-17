<?php namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Task extends Model { use SoftDeletes, LogsActivity;
    protected $fillable = ['business_id','facility_id','sub_facility_id','assigned_to','created_by','title','description','priority','due_at','completed_at','completed_by','is_recurring','recurrence_rule'];
    protected $casts = ['due_at'=>'datetime','completed_at'=>'datetime','recurrence_rule'=>'array'];
    public function business() { return $this->belongsTo(Business::class); }
    public function facility() { return $this->belongsTo(Facility::class); }
    public function subFacility() { return $this->belongsTo(SubFacility::class); }
    public function assignedTo() { return $this->belongsTo(User::class, 'assigned_to'); }
    public function createdBy() { return $this->belongsTo(User::class, 'created_by'); }
}

class CoshhChemical extends Model { use SoftDeletes, LogsActivity;
    protected $fillable = ['business_id','name','manufacturer','un_number','hazard_symbols','min_stock_level','current_stock_level','storage_location','handling_instructions','msds_file'];
}

class PoolTest extends Model { use LogsActivity;
    protected $fillable = ['sub_facility_id','user_id','temperature','free_chlorine','total_chlorine','ph','alkalinity','calcium_hardness','cyanuric_acid','is_out_of_range','notes','tested_at'];
    protected $casts = ['tested_at'=>'datetime'];
    public function subFacility() { return $this->belongsTo(SubFacility::class); }
    public function user() { return $this->belongsTo(User::class); }
}

class WaterMeterReading extends Model { use LogsActivity;
    protected $fillable = ['facility_id','meter_location','reading','reading_date','recorded_by'];
}

class ClubHire extends Model { use SoftDeletes, LogsActivity;
    protected $dates = ['insurance_expiry','qualification_expiry'];
}

class DailyOverview extends Model { use LogsActivity;
    protected $fillable = ['facility_id','overview_date','expected_guests','classes_today','special_events','notes','staff_on_shift'];
    protected $casts = ['overview_date'=>'date', 'staff_on_shift'=>'array'];
}

class MessageBoardPost extends Model { use LogsActivity;
    protected $fillable = ['facility_id','user_id','message','pinned'];
}
