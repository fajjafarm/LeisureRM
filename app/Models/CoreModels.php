<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Task extends Model { use SoftDeletes, LogsActivity;
    protected \ = ['business_id','facility_id','sub_facility_id','assigned_to','created_by','title','description','priority','due_at','completed_at','completed_by','is_recurring','recurrence_rule'];
    protected \ = ['due_at'=>'datetime','completed_at'=>'datetime','recurrence_rule'=>'array'];
}

class CoshhChemical extends Model { use SoftDeletes, LogsActivity;
    protected \ = ['business_id','name','manufacturer','un_number','hazard_symbols','min_stock_level','current_stock_level','storage_location','handling_instructions','msds_file'];
}

class PoolTest extends Model { use LogsActivity;
    protected \ = ['sub_facility_id','user_id','temperature','free_chlorine','total_chlorine','ph','alkalinity','calcium_hardness','cyanuric_acid','is_out_of_range','notes','tested_at'];
    protected \ = ['tested_at'=>'datetime'];
}
