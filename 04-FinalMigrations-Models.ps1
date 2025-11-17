# 04-FinalMigrations-Models.ps1
# # # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# 2025_11_17_000010_create_water_meter_readings_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('water_meter_readings', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            \$table->string('meter_location');
            \$table->decimal('reading', 12, 2);
            \$table->date('reading_date');
            \$table->foreignId('recorded_by')->constrained('users');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('water_meter_readings'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000010_create_water_meter_readings_table.php"

# 2025_11_17_000011_create_backwash_logs_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            \$table->foreignId('performed_by')->constrained('users');
            \$table->timestamp('performed_at');
            \$table->integer('duration_minutes')->nullable();
            \$table->text('notes')->nullable();
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('backwash_logs'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000011_create_backwash_logs_table.php"

# ___________________________________________________________
# MODELS (with Spatie ActivityLog + SoftDeletes + PWTAG rules)
# ___________________________________________________________

# app/Models/Business.php
@"
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Business extends Model {
    use SoftDeletes, LogsActivity;
    protected \$fillable = ['name','slug','contact_email','phone','address','settings','is_active'];
    protected \$casts = ['settings'=>'array','is_active'=>'boolean'];
    public function getActivitylogOptions(): LogOptions { return LogOptions::defaults()->logFillable(); }
    public function facilities() { return \$this->hasMany(Facility::class); }
    public function coshhChemicals() { return \$this->hasMany(CoshhChemical::class); }
}
"@ | Out-File -Encoding utf8 app/Models/Business.php

# app/Models/Facility.php
@"
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Facility extends Model {
    use SoftDeletes, LogsActivity;
    protected \$fillable = ['business_id','name','slug','address','postcode','is_active'];
    public function business() { return \$this->belongsTo(Business::class); }
    public function subFacilities() { return \$this->hasMany(SubFacility::class); }
}
"@ | Out-File -Encoding utf8 app/Models/Facility.php

# app/Models/SubFacility.php (with PWTAG parameter rules)
@"
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class SubFacility extends Model {
    use SoftDeletes, LogsActivity;
    protected \$fillable = ['facility_id','name','type','is_thermal_suite','check_interval_minutes','last_checked_at','parameters','requires_backwash','max_backwash_days','last_backwash_at'];
    protected \$casts = ['parameters'=>'array','last_checked_at'=>'datetime','last_backwash_at'=>'datetime'];
    
    public function getParameterRulesAttribute() {
        return match(\$this->type) {
            'pool','baby_pool' => ['temperature'=>['min'=>26,'max'=>32], 'free_chlorine'=>['min'=>1.0,'max'=>3.0], 'ph'=>['min'=>7.2,'max'=>7.6]],
            'hot_tub','turbo_spa' => ['temperature'=>['min'=>36,'max'=>40], 'free_chlorine'=>['min'=>3.0,'max'=>5.0]],
            'sauna','steam_room' => ['temperature'=>['min'=>70,'max'=>100]],
            default => []
        };
    }
    public function facility() { return \$this->belongsTo(Facility::class); }
    public function poolTests() { return \$this->hasMany(PoolTest::class); }
}
"@ | Out-File -Encoding utf8 app/Models/SubFacility.php

# app/Models/UserProfile.php + extend User
@"
<?php
namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Spatie\Permission\Traits\HasRoles;
use Spatie\Activitylog\Traits\LogsActivity;

class User extends Authenticatable {
    use HasRoles, LogsActivity;
    protected \$fillable = ['name','email','password'];
    protected \$hidden = ['password','remember_token'];
    public function profile() { return \$this->hasOne(UserProfile::class); }
    public function currentFacility() { return \$this->profile?->currentFacility; }
}

class UserProfile extends \Illuminate\Database\Eloquent\Model {
    protected \$fillable = ['user_id','business_id','current_facility_id','start_date','end_date','required_training_hours_per_month','training_hours_this_month'];
    public function user() { return \$this->belongsTo(User::class); }
    public function business() { return \$this->belongsTo(Business::class); }
    public function currentFacility() { return \$this->belongsTo(Facility::class, 'current_facility_id'); }
}
"@ | Out-File -Encoding utf8 app/Models/User.php

# Remaining key models (Task, CoshhChemical, PoolTest, etc.)
@"
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Task extends Model { use SoftDeletes, LogsActivity;
    protected \$fillable = ['business_id','facility_id','sub_facility_id','assigned_to','created_by','title','description','priority','due_at','completed_at','completed_by','is_recurring','recurrence_rule'];
    protected \$casts = ['due_at'=>'datetime','completed_at'=>'datetime','recurrence_rule'=>'array'];
}

class CoshhChemical extends Model { use SoftDeletes, LogsActivity;
    protected \$fillable = ['business_id','name','manufacturer','un_number','hazard_symbols','min_stock_level','current_stock_level','storage_location','handling_instructions','msds_file'];
}

class PoolTest extends Model { use LogsActivity;
    protected \$fillable = ['sub_facility_id','user_id','temperature','free_chlorine','total_chlorine','ph','alkalinity','calcium_hardness','cyanuric_acid','is_out_of_range','notes','tested_at'];
    protected \$casts = ['tested_at'=>'datetime'];
}
"@ | Out-File -Encoding utf8 app/Models/CoreModels.php

Write-Host "04 - Final migrations + all Eloquent models with PWTAG rules & audit trail created" -ForegroundColor Green
