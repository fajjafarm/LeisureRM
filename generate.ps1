```powershell
# Ensure the Laravel project structure exists
New-Item -ItemType Directory -Force -Path app\Models
New-Item -ItemType Directory -Force -Path app\Http\Controllers
New-Item -ItemType Directory -Force -Path database\migrations
New-Item -ItemType Directory -Force -Path resources\views\partials
New-Item -ItemType Directory -Force -Path resources\views\pool-tests
New-Item -ItemType Directory -Force -Path resources\views\chemical-stocks
New-Item -ItemType Directory -Force -Path resources\views\health-checks
New-Item -ItemType Directory -Force -Path resources\views\tasks
New-Item -ItemType Directory -Force -Path resources\views\qualifications
New-Item -ItemType Directory -Force -Path resources\views\training-sessions
New-Item -ItemType Directory -Force -Path resources\views\training\history
New-Item -ItemType Directory -Force -Path resources\views\training\stats
New-Item -ItemType Directory -Force -Path resources\views\water-meter-readings
New-Item -ItemType Directory -Force -Path resources\views\backwash-logs
New-Item -ItemType Directory -Force -Path resources\views\external-hire-clubs
New-Item -ItemType Directory -Force -Path resources\views\annual-inspection-items
New-Item -ItemType Directory -Force -Path app\Providers
New-Item -ItemType Directory -Force -Path app\Console

# app/Models/User.php
Set-Content -Path app\Models\User.php -Value @"
<?php

// File: app/Models/User.php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    protected `$fillable = [
        'name',
        'email',
        'password',
        'rank',
    ];

    protected `$hidden = [
        'password',
        'remember_token',
    ];

    protected `$casts = [
        'email_verified_at' => 'datetime',
        'rank' => 'string', // enum in migration
    ];

    public function businesses()
    {
        return `$this->belongsToMany(Business::class);
    }

    public function tasksAsAssigner()
    {
        return `$this->hasMany(Task::class, 'assigner_id');
    }

    public function tasksAsAssignee()
    {
        return `$this->hasMany(Task::class, 'assigned_to_user_id');
    }

    // Helper for rank priority
    public function rankPriority()
    {
        `$priorities = [
            'Manager' => 5,
            'Deputy Manager' => 4,
            'Assistant Manager' => 3,
            'Supervisor' => 2,
            'Assistant' => 1,
            null => 0,
        ];
        return `$priorities[`$this->rank] ?? 0;
    }
}
"@

# app/Models/Business.php
Set-Content -Path app\Models\Business.php -Value @"
<?php

// File: app/Models/Business.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Business extends Model
{
    use HasFactory;

    protected `$fillable = ['name', 'description'];

    public function facilities()
    {
        return `$this->hasMany(Facility::class);
    }

    public function users()
    {
        return `$this->belongsToMany(User::class);
    }
}
"@

# app/Models/Facility.php
Set-Content -Path app\Models\Facility.php -Value @"
<?php

// File: app/Models/Facility.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Facility extends Model
{
    use HasFactory;

    protected `$fillable = ['name', 'business_id'];

    public function business()
    {
        return `$this->belongsTo(Business::class);
    }

    public function subFacilities()
    {
        return `$this->hasMany(SubFacility::class);
    }

    public function users()
    {
        return `$this->belongsToMany(User::class);
    }
}
"@

# app/Models/SubFacility.php
Set-Content -Path app\Models\SubFacility.php -Value @"
<?php

// File: app/Models/SubFacility.php (Updated)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubFacility extends Model
{
    use HasFactory;

    protected `$fillable = [
        'name',
        'facility_id',
        'check_interval_minutes',
        'check_start_time',
        'check_end_time',
        'normal_daily_usage',
        'backwash_interval_days', // New field
    ];

    protected `$casts = [
        'check_start_time' => 'datetime:H:i',
        'check_end_time' => 'datetime:H:i',
    ];

    public function facility()
    {
        return `$this->belongsTo(Facility::class);
    }

    public function poolTests()
    {
        return `$this->hasMany(PoolTest::class);
    }

    public function healthChecks()
    {
        return `$this->hasMany(HealthCheck::class);
    }

    public function chemicalStocks()
    {
        return `$this->hasMany(ChemicalStock::class);
    }

    public function waterMeterReadings()
    {
        return `$this->hasMany(WaterMeterReading::class);
    }

    public function backwashLogs()
    {
        return `$this->hasMany(BackwashLog::class);
    }

    public function annualInspectionItems()
    {
        return `$this->hasMany(AnnualInspectionItem::class);
    }
}
"@

# app/Models/PoolTest.php
Set-Content -Path app\Models\PoolTest.php -Value @"
<?php

// File: app/Models/PoolTest.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

class PoolTest extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'user_id',
        'temperature',
        'ph',
        'chlorine',
        'alkalinity',
        'calcium_hardness',
        'tds',
        'balance_result',
    ];

    protected static function booted()
    {
        static::creating(function (`$model) {
            `$model->balance_result = `$model->calculateBalance();
        });

        static::updating(function (`$model) {
            `$model->balance_result = `$model->calculateBalance();
        });
    }

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    public function user()
    {
        return `$this->belongsTo(User::class);
    }

    public function calculateBalance(): float
    {
        `$tf = `$this->getTemperatureFactor(`$this->temperature);
        `$cf = `$this->getCalciumFactor(`$this->calcium_hardness);
        `$af = `$this->getAlkalinityFactor(`$this->alkalinity);
        `$result = `$this->ph + `$tf + `$cf + `$af - 12.1;

        // Log or notify if out of range
        if (`$result < -0.3 || `$result > 0.3) {
            Log::warning('Water balance out of range for PoolTest ID: ' . `$this->id);
        }

        return `$result;
    }

    private function getTemperatureFactor(float `$temp): float
    {
        if (`$temp <= 32) return 0.0;
        if (`$temp <= 37) return 0.1;
        if (`$temp <= 46) return 0.2;
        if (`$temp <= 53) return 0.3;
        if (`$temp <= 60) return 0.4;
        if (`$temp <= 66) return 0.5;
        if (`$temp <= 76) return 0.6;
        if (`$temp <= 84) return 0.7;
        if (`$temp <= 94) return 0.8;
        if (`$temp <= 105) return 0.9;
        return 1.0; // Approximate for higher
    }

    private function getCalciumFactor(float `$calcium): float
    {
        if (`$calcium <= 5) return 0.3;
        if (`$calcium <= 25) return 1.0;
        if (`$calcium <= 50) return 1.3;
        if (`$calcium <= 75) return 1.5;
        if (`$calcium <= 100) return 1.6;
        if (`$calcium <= 150) return 1.8;
        if (`$calcium <= 200) return 1.9;
        if (`$calcium <= 250) return 2.0;
        if (`$calcium <= 300) return 2.1;
        if (`$calcium <= 400) return 2.2;
        if (`$calcium <= 600) return 2.3;
        if (`$calcium <= 800) return 2.4;
        return 2.5; // For higher
    }

    private function getAlkalinityFactor(float `$alk): float
    {
        if (`$alk <= 5) return 0.7;
        if (`$alk <= 25) return 1.4;
        if (`$alk <= 50) return 1.7;
        if (`$alk <= 75) return 1.9;
        if (`$alk <= 100) return 2.0;
        if (`$alk <= 125) return 2.1;
        if (`$alk <= 150) return 2.2;
        if (`$alk <= 200) return 2.3;
        if (`$alk <= 250) return 2.4;
        if (`$alk <= 300) return 2.5;
        if (`$alk <= 400) return 2.6;
        if (`$alk <= 800) return 2.9;
        return 3.0; // Approximate
    }
}
"@

# app/Models/ChemicalStock.php
Set-Content -Path app\Models\ChemicalStock.php -Value @"
<?php

// File: app/Models/ChemicalStock.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChemicalStock extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'chemical_name',
        'quantity',
        'unit',
        'min_threshold',
    ];

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    public function isLow(): bool
    {
        return `$this->quantity < `$this->min_threshold;
    }
}
"@

# app/Models/HealthCheck.php
Set-Content -Path app\Models\HealthCheck.php -Value @"
<?php

// File: app/Models/HealthCheck.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HealthCheck extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'user_id',
        'notes',
        'status',
    ];

    protected `$casts = [
        'status' => 'string', // enum in migration
    ];

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    public function user()
    {
        return `$this->belongsTo(User::class);
    }
}
"@

# app/Models/Task.php
Set-Content -Path app\Models\Task.php -Value @"
<?php

// File: app/Models/Task.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected `$fillable = [
        'title',
        'description',
        'due_date',
        'priority',
        'assigned_to_user_id',
        'assigned_to_rank',
        'status',
        'assigner_id',
    ];

    protected `$casts = [
        'due_date' => 'datetime',
        'priority' => 'string',
        'status' => 'string',
    ];

    public function assigner()
    {
        return `$this->belongsTo(User::class, 'assigner_id');
    }

    public function assignee()
    {
        return `$this->belongsTo(User::class, 'assigned_to_user_id');
    }

    public function assignedToRankPriority()
    {
        `$priorities = [
            'Manager' => 5,
            'Deputy Manager' => 4,
            'Assistant Manager' => 3,
            'Supervisor' => 2,
            'Assistant' => 1,
        ];
        return `$priorities[`$this->assigned_to_rank] ?? 0;
    }
}
"@

# app/Models/Setting.php
Set-Content -Path app\Models\Setting.php -Value @"
<?php

// File: app/Models/Setting.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected `$fillable = ['key', 'value'];
}
"@

# app/Models/Qualification.php
Set-Content -Path app\Models\Qualification.php -Value @"
<?php

// File: app/Models/Qualification.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Qualification extends Model
{
    use HasFactory;

    protected `$fillable = ['name', 'description'];

    public function requiredRanks()
    {
        return `$this->belongsToMany(User::class, 'qualification_rank', 'qualification_id', 'rank')
            ->withPivot('required'); // Note: rank is string, so custom pivot
    }

    public function users()
    {
        return `$this->belongsToMany(User::class, 'user_qualifications')
            ->withPivot('obtained_date', 'expiry_date');
    }
}
"@

# app/Models/TrainingSession.php
Set-Content -Path app\Models\TrainingSession.php -Value @"
<?php

// File: app/Models/TrainingSession.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode; // Assume package installed: composer require simplesoftwareio/simple-qrcode

class TrainingSession extends Model
{
    use HasFactory;

    protected `$fillable = [
        'title',
        'date',
        'type', // e.g., 'CPR', 'General'
        'duration_hours',
        'qr_code',
        'created_by',
    ];

    protected `$casts = [
        'date' => 'datetime',
    ];

    public function creator()
    {
        return `$this->belongsTo(User::class, 'created_by');
    }

    public function attendances()
    {
        return `$this->hasMany(TrainingAttendance::class);
    }

    public function generateQrCode()
    {
        `$url = route('training.attend', ['session' => `$this->id, 'token' => Str::random(32)]); // Secure with token
        `$this->qr_code = QrCode::size(300)->generate(`$url);
        `$this->save();
    }
}
"@

# app/Models/TrainingAttendance.php
Set-Content -Path app\Models\TrainingAttendance.php -Value @"
<?php

// File: app/Models/TrainingAttendance.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrainingAttendance extends Model
{
    use HasFactory;

    protected `$fillable = [
        'training_session_id',
        'user_id',
        'attended_at',
        'score', // For CPR
    ];

    protected `$casts = [
        'attended_at' => 'datetime',
    ];

    public function session()
    {
        return `$this->belongsTo(TrainingSession::class);
    }

    public function user()
    {
        return `$this->belongsTo(User::class);
    }
}
"@

# app/Models/WaterMeterReading.php
Set-Content -Path app\Models\WaterMeterReading.php -Value @"
<?php

// File: app/Models/WaterMeterReading.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class WaterMeterReading extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'date',
        'reading',
    ];

    protected `$casts = [
        'date' => 'date',
    ];

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    // Get previous reading for usage calculation
    public function getPreviousReading()
    {
        return self::where('sub_facility_id', `$this->sub_facility_id)
            ->where('date', '<', `$this->date)
            ->orderBy('date', 'desc')
            ->first();
    }

    // Calculate daily usage
    public function getUsageAttribute(): float
    {
        `$previous = `$this->getPreviousReading();
        return `$previous ? `$this->reading - `$previous->reading : 0;
    }

    // Check if abnormal
    public function isAbnormal(float `$normalUsage): bool
    {
        return abs(`$this->usage - `$normalUsage) > 0; // Or add tolerance, e.g., > 10%
    }
}
"@

# app/Models/BackwashLog.php
Set-Content -Path app\Models\BackwashLog.php -Value @"
<?php

// File: app/Models/BackwashLog.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BackwashLog extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'user_id',
        'date',
        'duration_minutes',
        'water_used',
        'notes',
    ];

    protected `$casts = [
        'date' => 'datetime',
    ];

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    public function user()
    {
        return `$this->belongsTo(User::class);
    }
}
"@

# app/Models/ExternalHireClub.php
Set-Content -Path app\Models\ExternalHireClub.php -Value @"
<?php

// File: app/Models/ExternalHireClub.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExternalHireClub extends Model
{
    use HasFactory;

    protected `$fillable = [
        'facility_id',
        'name',
        'contact_details', // JSON: e.g., {'phone': '', 'email': ''}
        'safeguarding_contact',
        'notes',
    ];

    protected `$casts = [
        'contact_details' => 'array',
    ];

    public function facility()
    {
        return `$this->belongsTo(Facility::class);
    }

    public function documents()
    {
        return `$this->hasMany(ExternalHireDocument::class);
    }

    // Get current documents
    public function currentDocuments()
    {
        return `$this->documents()->where('is_current', true);
    }
}
"@

# app/Models/ExternalHireDocument.php
Set-Content -Path app\Models\ExternalHireDocument.php -Value @"
<?php

// File: app/Models/ExternalHireDocument.php (New Model for documents)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class ExternalHireDocument extends Model
{
    use HasFactory;

    protected `$fillable = [
        'external_hire_club_id',
        'type', // enum: 'qualification', 'insurance'
        'file_path',
        'expiry_date',
        'is_current',
    ];

    protected `$casts = [
        'expiry_date' => 'date',
        'is_current' => 'boolean',
    ];

    public function club()
    {
        return `$this->belongsTo(ExternalHireClub::class);
    }

    // Handle file upload in controller
}
"@

# app/Models/AnnualInspectionItem.php
Set-Content -Path app\Models\AnnualInspectionItem.php -Value @"
<?php

// File: app/Models/AnnualInspectionItem.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnnualInspectionItem extends Model
{
    use HasFactory;

    protected `$fillable = [
        'sub_facility_id',
        'name',
        'description',
        'inspection_interval_years',
    ];

    public function subFacility()
    {
        return `$this->belongsTo(SubFacility::class);
    }

    public function records()
    {
        return `$this->hasMany(AnnualInspectionRecord::class);
    }

    public function lastRecord()
    {
        return `$this->records()->latest('date')->first();
    }
}
"@

# app/Models/AnnualInspectionRecord.php
Set-Content -Path app\Models\AnnualInspectionRecord.php -Value @"
<?php

// File: app/Models/AnnualInspectionRecord.php (New Model)

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnnualInspectionRecord extends Model
{
    use HasFactory;

    protected `$fillable = [
        'annual_inspection_item_id',
        'date',
        'inspector_name',
        'details',
        'certificate_file',
    ];

    protected `$casts = [
        'date' => 'date',
    ];

    public function item()
    {
        return `$this->belongsTo(AnnualInspectionItem::class);
    }
}
"@

# database/migrations/0000_00_00_000000_create_users_table.php
Set-Content -Path database\migrations\0000_00_00_000000_create_users_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000000_create_users_table.php (adjust timestamp)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint `$table) {
            `$table->id();
            `$table->string('name');
            `$table->string('email')->unique();
            `$table->timestamp('email_verified_at')->nullable();
            `$table->string('password');
            `$table->enum('rank', ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant'])->nullable();
            `$table->rememberToken();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
"@

# database/migrations/0000_00_00_000001_create_businesses_table.php
Set-Content -Path database\migrations\0000_00_00_000001_create_businesses_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000001_create_businesses_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('businesses', function (Blueprint `$table) {
            `$table->id();
            `$table->string('name');
            `$table->text('description')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('businesses');
    }
};
"@

# database/migrations/0000_00_00_000002_create_facilities_table.php
Set-Content -Path database\migrations\0000_00_00_000002_create_facilities_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000002_create_facilities_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('facilities', function (Blueprint `$table) {
            `$table->id();
            `$table->string('name');
            `$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('facilities');
    }
};
"@

# database/migrations/0000_00_00_000003_create_sub_facilities_table.php
Set-Content -Path database\migrations\0000_00_00_000003_create_sub_facilities_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000003_create_sub_facilities_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sub_facilities', function (Blueprint `$table) {
            `$table->id();
            `$table->string('name');
            `$table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            `$table->integer('check_interval_minutes')->default(120);
            `$table->time('check_start_time')->default('08:00');
            `$table->time('check_end_time')->default('20:00');
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sub_facilities');
    }
};
"@

# database/migrations/0000_00_00_000004_create_pool_tests_table.php
Set-Content -Path database\migrations\0000_00_00_000004_create_pool_tests_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000004_create_pool_tests_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pool_tests', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->timestamp('tested_at')->useCurrent();
            `$table->float('temperature');
            `$table->float('ph');
            `$table->float('chlorine');
            `$table->float('alkalinity');
            `$table->float('calcium_hardness');
            `$table->float('tds')->nullable();
            `$table->float('balance_result');
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pool_tests');
    }
};
"@

# database/migrations/0000_00_00_000005_create_chemical_stocks_table.php
Set-Content -Path database\migrations\0000_00_00_000005_create_chemical_stocks_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000005_create_chemical_stocks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chemical_stocks', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->nullable()->constrained()->cascadeOnDelete();
            `$table->string('chemical_name');
            `$table->float('quantity');
            `$table->string('unit');
            `$table->float('min_threshold');
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chemical_stocks');
    }
};
"@

# database/migrations/0000_00_00_000006_create_health_checks_table.php
Set-Content -Path database\migrations\0000_00_00_000006_create_health_checks_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000006_create_health_checks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('health_checks', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->timestamp('checked_at')->useCurrent();
            `$table->text('notes')->nullable();
            `$table->enum('status', ['Passed', 'Failed', 'Maintenance']);
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('health_checks');
    }
};
"@

# database/migrations/0000_00_00_000007_create_tasks_table.php
Set-Content -Path database\migrations\0000_00_00_000007_create_tasks_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000007_create_tasks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint `$table) {
            `$table->id();
            `$table->string('title');
            `$table->text('description')->nullable();
            `$table->datetime('due_date')->nullable();
            `$table->enum('priority', ['Low', 'Medium', 'High']);
            `$table->foreignId('assigned_to_user_id')->nullable()->constrained('users')->cascadeOnDelete();
            `$table->enum('assigned_to_rank', ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant'])->nullable();
            `$table->enum('status', ['Pending', 'In Progress', 'Completed'])->default('Pending');
            `$table->foreignId('assigner_id')->constrained('users')->cascadeOnDelete();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
"@

# database/migrations/0000_00_00_000008_create_settings_table.php
Set-Content -Path database\migrations\0000_00_00_000008_create_settings_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000008_create_settings_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint `$table) {
            `$table->id();
            `$table->string('key')->unique();
            `$table->text('value')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
"@

# database/migrations/0000_00_00_000009_create_business_user_table.php
Set-Content -Path database\migrations\0000_00_00_000009_create_business_user_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000009_create_business_user_table.php (pivot)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('business_user', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('business_user');
    }
};
"@

# database/migrations/0000_00_00_000010_create_facility_user_table.php
Set-Content -Path database\migrations\0000_00_00_000010_create_facility_user_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000010_create_facility_user_table.php (pivot)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('facility_user', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('facility_user');
    }
};
"@

# database/migrations/0000_00_00_000011_create_qualifications_table.php
Set-Content -Path database\migrations\0000_00_00_000011_create_qualifications_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000011_create_qualifications_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('qualifications', function (Blueprint `$table) {
            `$table->id();
            `$table->string('name');
            `$table->text('description')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('qualifications');
    }
};
"@

# database/migrations/0000_00_00_000012_create_qualification_rank_table.php
Set-Content -Path database\migrations\0000_00_00_000012_create_qualification_rank_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000012_create_qualification_rank_table.php (Pivot for required per rank)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('qualification_rank', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            `$table->enum('rank', ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant']);
            `$table->boolean('required')->default(true);
            `$table->unique(['qualification_id', 'rank']);
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('qualification_rank');
    }
};
"@

# database/migrations/0000_00_00_000013_create_user_qualifications_table.php
Set-Content -Path database\migrations\0000_00_00_000013_create_user_qualifications_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000013_create_user_qualifications_table.php (Pivot for user quals)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_qualifications', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            `$table->date('obtained_date')->nullable();
            `$table->date('expiry_date')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_qualifications');
    }
};
"@

# database/migrations/0000_00_00_000014_create_training_sessions_table.php
Set-Content -Path database\migrations\0000_00_00_000014_create_training_sessions_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000014_create_training_sessions_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('training_sessions', function (Blueprint `$table) {
            `$table->id();
            `$table->string('title');
            `$table->datetime('date');
            `$table->string('type'); // e.g., 'CPR'
            `$table->float('duration_hours')->default(0);
            `$table->text('qr_code')->nullable();
            `$table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('training_sessions');
    }
};
"@

# database/migrations/0000_00_00_000015_create_training_attendances_table.php
Set-Content -Path database\migrations\0000_00_00_000015_create_training_attendances_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000015_create_training_attendances_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('training_attendances', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('training_session_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->datetime('attended_at')->useCurrent();
            `$table->float('score')->nullable(); // For CPR
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('training_attendances');
    }
};
"@

# database/migrations/0000_00_00_000016_create_water_meter_readings_table.php
Set-Content -Path database\migrations\0000_00_00_000016_create_water_meter_readings_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000016_create_water_meter_readings_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('water_meter_readings', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            `$table->date('date');
            `$table->float('reading');
            `$table->unique(['sub_facility_id', 'date']); // One per day per sub-facility
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('water_meter_readings');
    }
};
"@

# database/migrations/0000_00_00_000017_add_normal_daily_usage_to_sub_facilities.php
Set-Content -Path database\migrations\0000_00_00_000017_add_normal_daily_usage_to_sub_facilities.php -Value @"
<?php

// File: database/migrations/0000_00_00_000017_add_normal_daily_usage_to_sub_facilities.php (New Migration for update)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sub_facilities', function (Blueprint `$table) {
            `$table->float('normal_daily_usage')->default(0)->after('check_end_time');
        });
    }

    public function down(): void
    {
        Schema::table('sub_facilities', function (Blueprint `$table) {
            `$table->dropColumn('normal_daily_usage');
        });
    }
};
"@

# database/migrations/0000_00_00_000018_create_backwash_logs_table.php
Set-Content -Path database\migrations\0000_00_00_000018_create_backwash_logs_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000018_create_backwash_logs_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            `$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            `$table->datetime('date');
            `$table->integer('duration_minutes')->default(0);
            `$table->float('water_used')->default(0); // e.g., in liters or gallons
            `$table->text('notes')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('backwash_logs');
    }
};
"@

# database/migrations/0000_00_00_000019_add_backwash_interval_to_sub_facilities.php
Set-Content -Path database\migrations\0000_00_00_000019_add_backwash_interval_to_sub_facilities.php -Value @"
<?php

// File: database/migrations/0000_00_00_000019_add_backwash_interval_to_sub_facilities.php (New Migration for update)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sub_facilities', function (Blueprint `$table) {
            `$table->integer('backwash_interval_days')->default(7)->after('normal_daily_usage'); // e.g., weekly
        });
    }

    public function down(): void
    {
        Schema::table('sub_facilities', function (Blueprint `$table) {
            `$table->dropColumn('backwash_interval_days');
        });
    }
};
"@

# database/migrations/0000_00_00_000020_create_external_hire_clubs_table.php
Set-Content -Path database\migrations\0000_00_00_000020_create_external_hire_clubs_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000020_create_external_hire_clubs_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('external_hire_clubs', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            `$table->string('name');
            `$table->json('contact_details')->nullable();
            `$table->string('safeguarding_contact')->nullable();
            `$table->text('notes')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('external_hire_clubs');
    }
};
"@

# database/migrations/0000_00_00_000021_create_external_hire_documents_table.php
Set-Content -Path database\migrations\0000_00_00_000021_create_external_hire_documents_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000021_create_external_hire_documents_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('external_hire_documents', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('external_hire_club_id')->constrained()->cascadeOnDelete();
            `$table->enum('type', ['qualification', 'insurance']);
            `$table->string('file_path');
            `$table->date('expiry_date')->nullable();
            `$table->boolean('is_current')->default(true);
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('external_hire_documents');
    }
};
"@

# database/migrations/0000_00_00_000022_create_annual_inspection_items_table.php
Set-Content -Path database\migrations\0000_00_00_000022_create_annual_inspection_items_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000022_create_annual_inspection_items_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('annual_inspection_items', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('sub_facility_id')->nullable()->constrained()->cascadeOnDelete();
            `$table->string('name');
            `$table->text('description')->nullable();
            `$table->integer('inspection_interval_years')->default(1);
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('annual_inspection_items');
    }
};
"@

# database/migrations/0000_00_00_000023_create_annual_inspection_records_table.php
Set-Content -Path database\migrations\0000_00_00_000023_create_annual_inspection_records_table.php -Value @"
<?php

// File: database/migrations/0000_00_00_000023_create_annual_inspection_records_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('annual_inspection_records', function (Blueprint `$table) {
            `$table->id();
            `$table->foreignId('annual_inspection_item_id')->constrained()->cascadeOnDelete();
            `$table->date('date');
            `$table->string('inspector_name');
            `$table->text('details')->nullable();
            `$table->string('certificate_file')->nullable();
            `$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('annual_inspection_records');
    }
};
"@

# app/Http/Controllers/SuperAdminController.php
Set-Content -Path app\Http\Controllers\SuperAdminController.php -Value @"
<?php

// File: app/Http/Controllers/SuperAdminController.php

namespace App\Http\Controllers;

use App\Models\Business;
use App\Models\Facility;
use App\Models\SubFacility;
use App\Models\User;
use Illuminate\Http\Request;

class SuperAdminController extends Controller
{
    public function __construct()
    {
        `$this->middleware('role:SuperAdmin');
    }

    public function dashboard()
    {
        // Extend Osen dashboard
        return view('admin.dashboard'); // Assume Osen view
    }

    public function createBusiness(Request `$request)
    {
        `$validated = `$request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        Business::create(`$validated);

        return redirect()->back()->with('success', 'Business created.');
    }

    // Similar methods for edit, delete

    public function assignFacilities(Request `$request)
    {
        `$validated = `$request->validate([
            'business_id' => 'required|exists:businesses,id',
            'facility_ids' => 'array|exists:facilities,id',
        ]);

        `$business = Business::find(`$validated['business_id']);
        `$business->facilities()->sync(`$validated['facility_ids'] ?? []);

        return redirect()->back();
    }

    // Methods for SubFacilities, assignments, settings, etc.
}
"@

# app/Http/Controllers/PoolTestController.php
Set-Content -Path app\Http\Controllers\PoolTestController.php -Value @"
<?php

// File: app/Http/Controllers/PoolTestController.php

namespace App\Http\Controllers;

use App\Models\PoolTest;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PoolTestController extends Controller
{
    public function index(SubFacility `$subFacility)
    {
        `$tests = `$subFacility->poolTests()->latest()->paginate(20);
        return view('pool-tests.index', compact('tests', 'subFacility')); // Blade view
    }

    public function create(SubFacility `$subFacility)
    {
        return view('pool-tests.create', compact('subFacility'));
    }

    public function store(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'temperature' => 'required|numeric',
            'ph' => 'required|numeric',
            'chlorine' => 'required|numeric',
            'alkalinity' => 'required|numeric',
            'calcium_hardness' => 'required|numeric',
            'tds' => 'nullable|numeric',
        ]);

        `$validated['sub_facility_id'] = `$subFacility->id;
        `$validated['user_id'] = Auth::id();

        PoolTest::create(`$validated);

        return redirect()->route('pool-tests.index', `$subFacility)->with('success', 'Test recorded.');
    }

    // Edit, update, delete similar
}
"@

# app/Http/Controllers/ChemicalStockController.php
Set-Content -Path app\Http\Controllers\ChemicalStockController.php -Value @"
<?php

// File: app/Http/Controllers/ChemicalStockController.php

namespace App\Http\Controllers;

use App\Models\ChemicalStock;
use Illuminate\Http\Request;

class ChemicalStockController extends Controller
{
    public function index()
    {
        `$stocks = ChemicalStock::paginate(20);
        return view('chemical-stocks.index', compact('stocks'));
    }

    public function create()
    {
        return view('chemical-stocks.create');
    }

    public function store(Request `$request)
    {
        `$validated = `$request->validate([
            'sub_facility_id' => 'nullable|exists:sub_facilities,id',
            'chemical_name' => 'required|string',
            'quantity' => 'required|numeric',
            'unit' => 'required|string',
            'min_threshold' => 'required|numeric',
        ]);

        ChemicalStock::create(`$validated);

        return redirect()->route('chemical-stocks.index');
    }

    // Update for adding/subtracting quantity, etc.
}
"@

# app/Http/Controllers/HealthCheckController.php
Set-Content -Path app\Http\Controllers\HealthCheckController.php -Value @"
<?php

// File: app/Http/Controllers/HealthCheckController.php

namespace App\Http\Controllers;

use App\Models\HealthCheck;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HealthCheckController extends Controller
{
    public function index(SubFacility `$subFacility)
    {
        `$checks = `$subFacility->healthChecks()->latest()->paginate(20);
        return view('health-checks.index', compact('checks', 'subFacility'));
    }

    public function store(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'notes' => 'nullable|string',
            'status' => 'required|in:Passed,Failed,Maintenance',
        ]);

        `$validated['sub_facility_id'] = `$subFacility->id;
        `$validated['user_id'] = Auth::id();

        HealthCheck::create(`$validated);

        return redirect()->back()->with('success', 'Check recorded.');
    }
}
"@

# app/Http/Controllers/TaskController.php
Set-Content -Path app\Http\Controllers\TaskController.php -Value @"
<?php

// File: app/Http/Controllers/TaskController.php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;

class TaskController extends Controller
{
    public function index()
    {
        `$tasks = Task::where('assigned_to_user_id', Auth::id())
            ->orWhere('assigned_to_rank', Auth::user()->rank)
            ->paginate(20);
        return view('tasks.index', compact('tasks'));
    }

    public function create()
    {
        `$users = User::all(); // Filter by lower ranks
        `$ranks = ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant'];
        return view('tasks.create', compact('users', 'ranks'));
    }

    public function store(Request `$request)
    {
        `$validated = `$request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'required|in:Low,Medium,High',
            'assigned_to_user_id' => 'nullable|exists:users,id',
            'assigned_to_rank' => 'nullable|in:Manager,Deputy Manager,Assistant Manager,Supervisor,Assistant',
        ]);

        `$validated['assigner_id'] = Auth::id();

        `$task = Task::create(`$validated);

        Gate::authorize('assign-task', `$task);

        return redirect()->route('tasks.index');
    }

    // Update status, etc.
}
"@

# app/Http/Controllers/QualificationController.php
Set-Content -Path app\Http\Controllers\QualificationController.php -Value @"
<?php

// File: app/Http/Controllers/QualificationController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\Qualification;
use Illuminate\Http\Request;

class QualificationController extends Controller
{
    public function index()
    {
        `$qualifications = Qualification::all();
        return view('qualifications.index', compact('qualifications'));
    }

    public function create()
    {
        return view('qualifications.create');
    }

    public function store(Request `$request)
    {
        `$validated = `$request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        Qualification::create(`$validated);

        return redirect()->route('qualifications.index');
    }

    // Methods to assign required to ranks
    public function assignRequired(Request `$request, Qualification `$qualification)
    {
        `$validated = `$request->validate([
            'rank' => 'required|in:Manager,Deputy Manager,Assistant Manager,Supervisor,Assistant',
            'required' => 'boolean',
        ]);

        `$qualification->requiredRanks()->attach(`$validated['rank'], ['required' => `$validated['required'] ?? true]);

        return redirect()->back();
    }

    // Similar for user assignments
}
"@

# app/Http/Controllers/TrainingSessionController.php
Set-Content -Path app\Http\Controllers\TrainingSessionController.php -Value @"
<?php

// File: app/Http/Controllers/TrainingSessionController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\TrainingSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TrainingSessionController extends Controller
{
    // Restrict to managers, etc., via middleware or gates

    public function index()
    {
        `$sessions = TrainingSession::latest()->paginate(20);
        return view('training-sessions.index', compact('sessions'));
    }

    public function create()
    {
        return view('training-sessions.create');
    }

    public function store(Request `$request)
    {
        `$validated = `$request->validate([
            'title' => 'required|string',
            'date' => 'required|date',
            'type' => 'required|string',
            'duration_hours' => 'required|numeric',
        ]);

        `$validated['created_by'] = Auth::id();

        `$session = TrainingSession::create(`$validated);
        `$session->generateQrCode();

        return redirect()->route('training-sessions.index');
    }

    // Show QR code in view
}
"@

# app/Http/Controllers/TrainingAttendanceController.php
Set-Content -Path app\Http\Controllers\TrainingAttendanceController.php -Value @"
<?php

// File: app/Http/Controllers/TrainingAttendanceController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\TrainingSession;
use App\Models\TrainingAttendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TrainingAttendanceController extends Controller
{
    public function attend(Request `$request, TrainingSession `$session)
    {
        // Validate token if used
        `$validated = `$request->validate([
            'score' => 'nullable|numeric|required_if:type,CPR', // Conditional
        ]);

        TrainingAttendance::create([
            'training_session_id' => `$session->id,
            'user_id' => Auth::id(),
            'score' => `$validated['score'] ?? null,
        ]);

        return redirect()->back()->with('success', 'Attendance recorded.');
    }

    // For charts and tables
    public function individualHistory(User `$user)
    {
        `$attendances = `$user->trainingAttendances()->with('session')->get();
        // Prepare data for table and chart (e.g., scores over time)
        return view('training.history.individual', compact('attendances', 'user'));
    }

    public function teamStats()
    {
        // Monthly averages
        `$monthlyData = TrainingAttendance::selectRaw('YEAR(attended_at) as year, MONTH(attended_at) as month, AVG(score) as avg_score, SUM(session.duration_hours) as total_hours')
            ->join('training_sessions as session', 'training_attendances.training_session_id', '=', 'session.id')
            ->groupBy('year', 'month')
            ->get();

        // For charts: Use JSON for Chart.js in view
        return view('training.stats.team', compact('monthlyData'));
    }
}
"@

# app/Http/Controllers/WaterMeterReadingController.php
Set-Content -Path app\Http\Controllers\WaterMeterReadingController.php -Value @"
<?php

// File: app/Http/Controllers/WaterMeterReadingController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\SubFacility;
use App\Models\WaterMeterReading;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;

class WaterMeterReadingController extends Controller
{
    public function index(SubFacility `$subFacility)
    {
        `$readings = `$subFacility->waterMeterReadings()
            ->where('date', '>=', Carbon::now()->subDays(30))
            ->orderBy('date', 'desc')
            ->get();

        `$normalUsage = `$subFacility->normal_daily_usage;

        // Prepare chart data
        `$chartLabels = `$readings->pluck('date')->map(fn(`$date) => `$date->format('Y-m-d'));
        `$chartData = `$readings->pluck('usage');

        // Check for abnormal and create tasks
        foreach (`$readings as `$reading) {
            if (`$reading->isAbnormal(`$normalUsage)) {
                `$this->createAbnormalUsageTask(`$reading);
            }
        }

        return view('water-meter-readings.index', compact('readings', 'subFacility', 'normalUsage', 'chartLabels', 'chartData'));
    }

    public function create(SubFacility `$subFacility)
    {
        return view('water-meter-readings.create', compact('subFacility'));
    }

    public function store(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'date' => 'required|date',
            'reading' => 'required|numeric',
        ]);

        `$validated['sub_facility_id'] = `$subFacility->id;

        `$reading = WaterMeterReading::create(`$validated);

        `$normalUsage = `$subFacility->normal_daily_usage;
        if (`$reading->isAbnormal(`$normalUsage)) {
            `$this->createAbnormalUsageTask(`$reading);
        }

        return redirect()->route('water-meter-readings.index', `$subFacility)->with('success', 'Reading recorded.');
    }

    private function createAbnormalUsageTask(WaterMeterReading `$reading)
    {
        // Check if task already exists for this
        `$existing = Task::where('title', 'like', "%Water Usage Check for {`$reading->date}%")->first();
        if (`$existing) return;

        Task::create([
            'title' => "Abnormal Water Usage Check for {`$reading->date}",
            'description' => "Usage: {`$reading->usage}. Normal: {`$reading->subFacility->normal_daily_usage}. Please investigate.",
            'priority' => 'High',
            'assigned_to_rank' => 'Supervisor', // Or higher; can assign to multiple if needed
            'status' => 'Pending',
            'assigner_id' => Auth::id() ?? 1, // System or current user
        ]);
    }

    // Update normal usage
    public function updateNormalUsage(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'normal_daily_usage' => 'required|numeric',
        ]);

        `$subFacility->update(`$validated);

        return redirect()->back()->with('success', 'Normal usage updated.');
    }
}
"@

# app/Http/Controllers/BackwashLogController.php
Set-Content -Path app\Http\Controllers\BackwashLogController.php -Value @"
<?php

// File: app/Http/Controllers/BackwashLogController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\BackwashLog;
use App\Models\SubFacility;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Carbon;

class BackwashLogController extends Controller
{
    public function index(SubFacility `$subFacility)
    {
        `$logs = `$subFacility->backwashLogs()->latest()->paginate(20);
        `$lastBackwash = `$subFacility->backwashLogs()->latest()->first();
        `$isOverdue = `$lastBackwash ? Carbon::now()->diffInDays(`$lastBackwash->date) > `$subFacility->backwash_interval_days : true;

        if (`$isOverdue) {
            `$this->createOverdueTask(`$subFacility);
        }

        // Chart data: frequency over time (e.g., monthly backwashes)
        `$chartData = `$logs->groupBy(function (`$log) {
            return `$log->date->format('Y-m');
        })->map->count();

        return view('backwash-logs.index', compact('logs', 'subFacility', 'isOverdue', 'chartData'));
    }

    public function create(SubFacility `$subFacility)
    {
        return view('backwash-logs.create', compact('subFacility'));
    }

    public function store(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'date' => 'required|date',
            'duration_minutes' => 'required|integer',
            'water_used' => 'required|numeric',
            'notes' => 'nullable|string',
        ]);

        `$validated['sub_facility_id'] = `$subFacility->id;
        `$validated['user_id'] = Auth::id();

        BackwashLog::create(`$validated);

        // Optional: Link to water usage if integrated

        return redirect()->route('backwash-logs.index', `$subFacility)->with('success', 'Backwash logged.');
    }

    private function createOverdueTask(SubFacility `$subFacility)
    {
        `$existing = Task::where('title', 'like', "%Overdue Backwash for {`$subFacility->name}%")->where('status', 'Pending')->first();
        if (`$existing) return;

        Task::create([
            'title' => "Overdue Backwash for {`$subFacility->name}",
            'description' => "Last backwash was more than {`$subFacility->backwash_interval_days} days ago. Please perform backwash.",
            'priority' => 'Medium',
            'assigned_to_rank' => 'Supervisor',
            'status' => 'Pending',
            'assigner_id' => Auth::id() ?? 1,
        ]);
    }

    // Update interval
    public function updateInterval(Request `$request, SubFacility `$subFacility)
    {
        `$validated = `$request->validate([
            'backwash_interval_days' => 'required|integer|min:1',
        ]);

        `$subFacility->update(`$validated);

        return redirect()->back()->with('success', 'Backwash interval updated.');
    }
}
"@

# app/Http/Controllers/ExternalHireClubController.php
Set-Content -Path app\Http\Controllers\ExternalHireClubController.php -Value @"
<?php

// File: app/Http/Controllers/ExternalHireClubController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\ExternalHireClub;
use App\Models\Facility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ExternalHireClubController extends Controller
{
    public function index(Facility `$facility)
    {
        `$clubs = `$facility->externalHireClubs()->paginate(20);
        return view('external-hire-clubs.index', compact('clubs', 'facility'));
    }

    public function create(Facility `$facility)
    {
        return view('external-hire-clubs.create', compact('facility'));
    }

    public function store(Request `$request, Facility `$facility)
    {
        `$validated = `$request->validate([
            'name' => 'required|string|max:255',
            'contact_details' => 'nullable|json',
            'safeguarding_contact' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        `$validated['facility_id'] = `$facility->id;

        `$club = ExternalHireClub::create(`$validated);

        // Handle document uploads
        `$this->handleDocuments(`$request, `$club);

        return redirect()->route('external-hire-clubs.index', `$facility)->with('success', 'Club added.');
    }

    public function update(Request `$request, ExternalHireClub `$club)
    {
        `$validated = `$request->validate([
            'name' => 'required|string|max:255',
            'contact_details' => 'nullable|json',
            'safeguarding_contact' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        `$club->update(`$validated);

        // Handle new documents (archive old if replacing)
        if (`$request->hasFile('qualifications') || `$request->hasFile('insurance')) {
            `$club->documents()->update(['is_current' => false]); // Archive old
            `$this->handleDocuments(`$request, `$club);
        }

        return redirect()->back()->with('success', 'Club updated.');
    }

    private function handleDocuments(Request `$request, ExternalHireClub `$club)
    {
        if (`$request->hasFile('qualifications')) {
            foreach (`$request->file('qualifications') as `$file) {
                `$path = `$file->store('documents/qualifications');
                `$club->documents()->create([
                    'type' => 'qualification',
                    'file_path' => `$path,
                    'expiry_date' => `$request->input('qual_expiry'), // Assume input
                    'is_current' => true,
                ]);
            }
        }

        if (`$request->hasFile('insurance')) {
            `$path = `$request->file('insurance')->store('documents/insurance');
            `$club->documents()->create([
                'type' => 'insurance',
                'file_path' => `$path,
                'expiry_date' => `$request->input('ins_expiry'),
                'is_current' => true,
            ]);
        }
    }

    // View historical documents in index or show view
}
"@

# app/Http/Controllers/AnnualInspectionItemController.php
Set-Content -Path app\Http\Controllers\AnnualInspectionItemController.php -Value @"
<?php

// File: app/Http/Controllers/AnnualInspectionItemController.php (New Controller)

namespace App\Http\Controllers;

use App\Models\AnnualInspectionItem;
use App\Models\SubFacility;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AnnualInspectionItemController extends Controller
{
    public function index(SubFacility `$subFacility = null)
    {
        `$items = `$subFacility ? `$subFacility->annualInspectionItems()->paginate(20) : AnnualInspectionItem::paginate(20);
        return view('annual-inspection-items.index', compact('items', 'subFacility'));
    }

    public function create(SubFacility `$subFacility = null)
    {
        return view('annual-inspection-items.create', compact('subFacility'));
    }

    public function store(Request `$request, SubFacility `$subFacility = null)
    {
        `$validated = `$request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'inspection_interval_years' => 'integer|min:1',
        ]);

        if (`$subFacility) {
            `$validated['sub_facility_id'] = `$subFacility->id;
        }

        `$item = AnnualInspectionItem::create(`$validated);

        // Handle initial record if provided
        `$this->handleRecord(`$request, `$item);

        return redirect()->route('annual-inspection-items.index', `$subFacility)->with('success', 'Item added.');
    }

    public function addRecord(Request `$request, AnnualInspectionItem `$item)
    {
        `$this->handleRecord(`$request, `$item);
        return redirect()->back()->with('success', 'Record added.');
    }

    private function handleRecord(Request `$request, AnnualInspectionItem `$item)
    {
        `$validated = `$request->validate([
            'date' => 'required|date',
            'inspector_name' => 'required|string',
            'details' => 'nullable|string',
            'certificate_file' => 'nullable|file|mimes:pdf,jpg,png',
        ]);

        if (`$request->hasFile('certificate_file')) {
            `$validated['certificate_file'] = `$request->file('certificate_file')->store('inspections/certificates');
        }

        `$item->records()->create(`$validated);
    }
}
"@

# resources/views/partials/sidebar.blade.php
Set-Content -Path resources\views\partials\sidebar.blade.php -Value @"
<!-- File: resources/views/partials/sidebar.blade.php (Updated excerpt) -->

<ul class="sidebar-menu">
    @foreach (auth()->user()->businesses as `$business)
        <li>
            <a href="#">{{ `$business->name }}</a>
            <ul>
                @foreach (`$business->facilities as `$facility)
                    <li>
                        <a href="#">{{ `$facility->name }}</a>
                        <ul>
                            @foreach (`$facility->subFacilities as `$subFacility)
                                @php
                                    `$lastCheck = `$subFacility->healthChecks()->latest()->first();
                                    `$isOverdue = `$lastCheck ? now()->diffInMinutes(`$lastCheck->checked_at) > `$subFacility->check_interval_minutes : true;
                                    `$lastBackwash = `$subFacility->backwashLogs()->latest()->first();
                                    `$isBackwashOverdue = `$lastBackwash ? now()->diffInDays(`$lastBackwash->date) > `$subFacility->backwash_interval_days : true;
                                    `$class = `$isOverdue || `$isBackwashOverdue ? 'overdue' : '';
                                @endphp
                                <li class="{{ `$class }}">
                                    <a href="{{ route('health-checks.index', `$subFacility) }}">{{ `$subFacility->name }}</a>
                                    <!-- Add link to backwash-logs if needed -->
                                </li>
                            @endforeach
                        </ul>
                    </li>
                @endforeach
            </ul>
        </li>
    @endforeach
</ul>

<style>
    .overdue { color: red; font-weight: bold; }
</style>

<!-- Add links under Facility/SubFacility, e.g., -->
<li><a href="{{ route('external-hire-clubs.index', `$facility) }}">External Hires</a></li>
<li><a href="{{ route('annual-inspection-items.index') }}">Annual Inspections</a></li>
"@

# resources/views/pool-tests/create.blade.php
Set-Content -Path resources\views\pool-tests\create.blade.php -Value @"
<!-- File: resources/views/pool-tests/create.blade.php -->

@extends('admin.layout') <!-- Assume Osen layout -->

@section('content')
    <h1>Record Pool Test for {{ `$subFacility->name }}</h1>
    <form method="POST" action="{{ route('pool-tests.store', `$subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Temperature</label>
            <input type="number" name="temperature" step="0.1" required class="form-control">
        </div>
        <div class="form-group">
            <label>pH</label>
            <input type="number" name="ph" step="0.1" required class="form-control">
        </div>
        <!-- Similar for other fields -->
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
@endsection
"@

# resources/views/pool-tests/index.blade.php
Set-Content -Path resources\views\pool-tests\index.blade.php -Value @"
<!-- File: resources/views/pool-tests/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Pool Tests for {{ `$subFacility->name }}</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Temperature</th>
                <th>pH</th>
                <!-- Other columns -->
                <th>Balance Result</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$tests as `$test)
                <tr>
                    <td>{{ `$test->tested_at }}</td>
                    <td>{{ `$test->temperature }}</td>
                    <td>{{ `$test->ph }}</td>
                    <!-- Others -->
                    <td>{{ `$test->balance_result }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    {{ `$tests->links() }}
@endsection
"@

# resources/views/qualifications/index.blade.php
Set-Content -Path resources\views\qualifications\index.blade.php -Value @"
<!-- File: resources/views/qualifications/index.blade.php (Example View) -->

@extends('admin.layout')

@section('content')
    <h1>Qualifications</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Required for Ranks</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$qualifications as `$qual)
                <tr>
                    <td>{{ `$qual->name }}</td>
                    <td>{{ `$qual->description }}</td>
                    <td>
                        @foreach (`$qual->requiredRanks as `$rank => `$pivot)
                            {{ `$rank }}: {{ `$pivot->required ? 'Yes' : 'No' }}
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
"@

# resources/views/training-sessions/create.blade.php
Set-Content -Path resources\views\training-sessions\create.blade.php -Value @"
<!-- File: resources/views/training-sessions/create.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>Create Training Session</h1>
    <form method="POST" action="{{ route('training-sessions.store') }}">
        @csrf
        <div class="form-group">
            <label>Title</label>
            <input type="text" name="title" required class="form-control">
        </div>
        <div class="form-group">
            <label>Date</label>
            <input type="datetime-local" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Type</label>
            <input type="text" name="type" required class="form-control">
        </div>
        <div class="form-group">
            <label>Duration (hours)</label>
            <input type="number" name="duration_hours" step="0.1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Create</button>
    </form>
@endsection
"@

# resources/views/training-sessions/show.blade.php
Set-Content -Path resources\views\training-sessions\show.blade.php -Value @"
<!-- File: resources/views/training-sessions/show.blade.php (For QR) -->

@extends('admin.layout')

@section('content')
    <h1>{{ `$session->title }}</h1>
    {!! `$session->qr_code !!} <!-- Display SVG QR -->
@endsection
"@

# resources/views/training/history/individual.blade.php
Set-Content -Path resources\views\training\history\individual.blade.php -Value @"
<!-- File: resources/views/training/history/individual.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Training History for {{ `$user->name }}</h1>
    <table class="table">
        <!-- Columns: Session Title, Date, Type, Score, Duration -->
        @foreach (`$attendances as `$att)
            <tr>
                <td>{{ `$att->session->title }}</td>
                <td>{{ `$att->attended_at }}</td>
                <td>{{ `$att->session->type }}</td>
                <td>{{ `$att->score ?? 'N/A' }}</td>
                <td>{{ `$att->session->duration_hours }}</td>
            </tr>
        @endforeach
    </table>
    <!-- Chart: e.g., <canvas id="scoreChart"></canvas> -->
    <script>
        // Use Chart.js to plot scores over time
        var ctx = document.getElementById('scoreChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [@json(`$attendances->pluck('attended_at'))],
                datasets: [{
                    label: 'Scores',
                    data: [@json(`$attendances->pluck('score'))],
                }]
            },
        });
    </script>
@endsection
"@

# resources/views/training/stats/team.blade.php
Set-Content -Path resources\views\training\stats\team.blade.php -Value @"
<!-- File: resources/views/training/stats/team.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Team Training Stats</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Month</th>
                <th>Avg Score</th>
                <th>Total Hours</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$monthlyData as `$data)
                <tr>
                    <td>{{ `$data->year }}-{{ `$data->month }}</td>
                    <td>{{ `$data->avg_score }}</td>
                    <td>{{ `$data->total_hours }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    <!-- Charts similar to above, bar for monthly avg, etc. -->
@endsection
"@

# resources/views/water-meter-readings/index.blade.php
Set-Content -Path resources\views\water-meter-readings\index.blade.php -Value @"
<!-- File: resources/views/water-meter-readings/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Water Meter Readings for {{ `$subFacility->name }} (Last 30 Days)</h1>

    <!-- Bar Chart -->
    <canvas id="usageChart" width="400" height="200"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var ctx = document.getElementById('usageChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: @json(`$chartLabels),
                datasets: [{
                    label: 'Daily Usage',
                    data: @json(`$chartData),
                    backgroundColor: @json(`$chartData->map(fn(`$usage) => abs(`$usage - `$normalUsage) > 0 ? 'red' : 'green')),
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
    </script>

    <!-- Table -->
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Reading</th>
                <th>Usage</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$readings as `$reading)
                @php
                    `$isAbnormal = abs(`$reading->usage - `$normalUsage) > 0; // Adjust tolerance
                    `$class = `$isAbnormal ? 'table-danger' : 'table-success';
                @endphp
                <tr class="{{ `$class }}">
                    <td>{{ `$reading->date->format('Y-m-d') }}</td>
                    <td>{{ `$reading->reading }}</td>
                    <td>{{ `$reading->usage }}</td>
                    <td>{{ `$isAbnormal ? 'Abnormal' : 'Normal' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Form to update normal usage -->
    <h2>Update Normal Daily Usage</h2>
    <form method="POST" action="{{ route('water-meter-readings.update-normal', `$subFacility) }}">
        @csrf
        @method('PATCH')
        <div class="form-group">
            <label>Normal Daily Usage</label>
            <input type="number" name="normal_daily_usage" value="{{ `$normalUsage }}" step="0.1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Update</button>
    </form>
@endsection
"@

# resources/views/water-meter-readings/create.blade.php
Set-Content -Path resources\views\water-meter-readings\create.blade.php -Value @"
<!-- File: resources/views/water-meter-readings/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Record Water Meter Reading for {{ `$subFacility->name }}</h1>
    <form method="POST" action="{{ route('water-meter-readings.store', `$subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Date</label>
            <input type="date" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Reading</label>
            <input type="number" name="reading" step="0.01" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
@endsection
"@

# resources/views/backwash-logs/index.blade.php
Set-Content -Path resources\views\backwash-logs\index.blade.php -Value @"
<!-- File: resources/views/backwash-logs/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Backwash Logs for {{ `$subFacility->name }}</h1>
    @if (`$isOverdue)
        <div class="alert alert-warning">Backwash is overdue!</div>
    @endif

    <!-- Chart: Bar for monthly frequency -->
    <canvas id="backwashChart" width="400" height="200"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var ctx = document.getElementById('backwashChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: @json(`$chartData->keys()),
                datasets: [{
                    label: 'Backwashes per Month',
                    data: @json(`$chartData->values()),
                    backgroundColor: 'blue',
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true, stepSize: 1 }
                }
            }
        });
    </script>

    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Duration (min)</th>
                <th>Water Used</th>
                <th>Notes</th>
                <th>User</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$logs as `$log)
                <tr>
                    <td>{{ `$log->date }}</td>
                    <td>{{ `$log->duration_minutes }}</td>
                    <td>{{ `$log->water_used }}</td>
                    <td>{{ `$log->notes }}</td>
                    <td>{{ `$log->user->name }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    {{ `$logs->links() }}

    <!-- Form to update interval -->
    <h2>Update Backwash Interval</h2>
    <form method="POST" action="{{ route('backwash-logs.update-interval', `$subFacility) }}">
        @csrf
        @method('PATCH')
        <div class="form-group">
            <label>Interval (days)</label>
            <input type="number" name="backwash_interval_days" value="{{ `$subFacility->backwash_interval_days }}" min="1" required class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Update</button>
    </form>
@endsection
"@

# resources/views/backwash-logs/create.blade.php
Set-Content -Path resources\views\backwash-logs\create.blade.php -Value @"
<!-- File: resources/views/backwash-logs/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Log Backwash for {{ `$subFacility->name }}</h1>
    <form method="POST" action="{{ route('backwash-logs.store', `$subFacility) }}">
        @csrf
        <div class="form-group">
            <label>Date</label>
            <input type="datetime-local" name="date" required class="form-control">
        </div>
        <div class="form-group">
            <label>Duration (minutes)</label>
            <input type="number" name="duration_minutes" required class="form-control">
        </div>
        <div class="form-group">
            <label>Water Used (e.g., liters)</label>
            <input type="number" name="water_used" step="0.1" required class="form-control">
        </div>
        <div class="form-group">
            <label>Notes</label>
            <textarea name="notes" class="form-control"></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Log Backwash</button>
    </form>
@endsection
"@

# resources/views/external-hire-clubs/index.blade.php
Set-Content -Path resources\views\external-hire-clubs\index.blade.php -Value @"
<!-- File: resources/views/external-hire-clubs/index.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>External Hire Clubs for {{ `$facility->name }}</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Contact</th>
                <th>Safeguarding</th>
                <th>Notes</th>
                <th>Documents</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$clubs as `$club)
                <tr>
                    <td>{{ `$club->name }}</td>
                    <td>{{ json_encode(`$club->contact_details) }}</td>
                    <td>{{ `$club->safeguarding_contact }}</td>
                    <td>{{ `$club->notes }}</td>
                    <td>
                        @foreach (`$club->documents as `$doc)
                            <a href="{{ Storage::url(`$doc->file_path) }}" target="_blank">{{ `$doc->type }} ({{ `$doc->is_current ? 'Current' : 'Archived' }}) - Exp: {{ `$doc->expiry_date }}</a><br>
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
"@

# resources/views/external-hire-clubs/create.blade.php
Set-Content -Path resources\views\external-hire-clubs\create.blade.php -Value @"
<!-- File: resources/views/external-hire-clubs/create.blade.php (Example) -->

@extends('admin.layout')

@section('content')
    <h1>Add External Hire Club</h1>
    <form method="POST" action="{{ route('external-hire-clubs.store', `$facility) }}" enctype="multipart/form-data">
        @csrf
        <div class="form-group">
            <label>Name</label>
            <input type="text" name="name" required class="form-control">
        </div>
        <div class="form-group">
            <label>Contact Details (JSON)</label>
            <textarea name="contact_details" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Safeguarding Contact</label>
            <input type="text" name="safeguarding_contact" class="form-control">
        </div>
        <div class="form-group">
            <label>Notes</label>
            <textarea name="notes" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Qualifications (multiple)</label>
            <input type="file" name="qualifications[]" multiple>
            <label>Expiry</label>
            <input type="date" name="qual_expiry">
        </div>
        <div class="form-group">
            <label>Insurance</label>
            <input type="file" name="insurance">
            <label>Expiry</label>
            <input type="date" name="ins_expiry">
        </div>
        <button type="submit" class="btn btn-primary">Add</button>
    </form>
@endsection
"@

# resources/views/annual-inspection-items/index.blade.php
Set-Content -Path resources\views\annual-inspection-items\index.blade.php -Value @"
<!-- File: resources/views/annual-inspection-items/index.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Annual Inspection Items</h1>
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Interval (years)</th>
                <th>Last Inspection</th>
                <th>Records</th>
            </tr>
        </thead>
        <tbody>
            @foreach (`$items as `$item)
                <tr>
                    <td>{{ `$item->name }}</td>
                    <td>{{ `$item->description }}</td>
                    <td>{{ `$item->inspection_interval_years }}</td>
                    <td>{{ `$item->lastRecord()?->date }}</td>
                    <td>
                        @foreach (`$item->records as `$rec)
                            <a href="{{ Storage::url(`$rec->certificate_file) }}" target="_blank">Record {{ `$rec->date }} by {{ `$rec->inspector_name }}</a><br>
                        @endforeach
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
@endsection
"@

# resources/views/annual-inspection-items/create.blade.php
Set-Content -Path resources\views\annual-inspection-items\create.blade.php -Value @"
<!-- File: resources/views/annual-inspection-items/create.blade.php -->

@extends('admin.layout')

@section('content')
    <h1>Add Annual Inspection Item</h1>
    <form method="POST" action="{{ route('annual-inspection-items.store') }}" enctype="multipart/form-data">
        @csrf
        <div class="form-group">
            <label>Name</label>
            <input type="text" name="name" required class="form-control">
        </div>
        <div class="form-group">
            <label>Description</label>
            <textarea name="description" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Interval (years)</label>
            <input type="number" name="inspection_interval_years" value="1" min="1" required class="form-control">
        </div>
        <!-- Optional initial record -->
        <h2>Initial Record</h2>
        <div class="form-group">
            <label>Date</label>
            <input type="date" name="date" class="form-control">
        </div>
        <div class="form-group">
            <label>Inspector Name</label>
            <input type="text" name="inspector_name" class="form-control">
        </div>
        <div class="form-group">
            <label>Details</label>
            <textarea name="details" class="form-control"></textarea>
        </div>
        <div class="form-group">
            <label>Certificate</label>
            <input type="file" name="certificate_file">
        </div>
        <button type="submit" class="btn btn-primary">Add</button>
    </form>
@endsection
"@

# app/Providers/AuthServiceProvider.php
Set-Content -Path app\Providers\AuthServiceProvider.php -Value @"
<?php

// File: app/Providers/AuthServiceProvider.php (excerpt for gates)

namespace App\Providers;

// ...

class AuthServiceProvider extends ServiceProvider
{
    // ...

    public function boot()
    {
        Gate::define('assign-task', function (`$user, `$task) {
            if (`$task->assigned_to_user_id) {
                return `$user->rankPriority() > `$task->assignee->rankPriority();
            }
            return `$user->rankPriority() > `$task->assignedToRankPriority();
        });

        // e.g., Gate for creating sessions: only managers+
        Gate::define('create-training', function (`$user) {
            return `$user->rankPriority() >= 3; // Assistant Manager+
        });
    }
}
"@

# app/Console/Kernel.php
Set-Content -Path app\Console\Kernel.php -Value @"
<?php

// File: app/Console/Kernel.php (for cron reminders)

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use App\Models\SubFacility;
use Illuminate\Support\Facades\Mail;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule `$schedule): void
    {
        `$schedule->call(function () {
            SubFacility::all()->each(function (`$sub) {
                `$lastCheck = `$sub->healthChecks()->latest()->first();
                if (`$lastCheck && now()->diffInMinutes(`$lastCheck->checked_at) > `$sub->check_interval_minutes
                    && now()->between(`$sub->check_start_time, `$sub->check_end_time)) {
                    // Send email reminder
                    Mail::to('admin@example.com')->send(new \App\Mail\OverdueCheck(`$sub));
                }
            });
        })->everyMinute(); // Or hourly

        // Existing schedules...

        `$schedule->call(function () {
            SubFacility::all()->each(function (`$sub) {
                `$lastBackwash = `$sub->backwashLogs()->latest()->first();
                if (`$lastBackwash && now()->diffInDays(`$lastBackwash->date) > `$sub->backwash_interval_days) {
                    // Create task or email
                    app(BackwashLogController::class)->createOverdueTask(`$sub);
                }
            });
        })->daily(); // Or as needed

        `$schedule->call(function () {
            // External Hire Reminders
            ExternalHireDocument::where('is_current', true)
                ->where('expiry_date', '<', now()->addDays(30)) // Remind 30 days before expiry
                ->get()
                ->each(function (`$doc) {
                    `$existing = Task::where('title', 'like', "%Renew {`$doc->type} for {`$doc->club->name}%")->where('status', 'Pending')->first();
                    if (`$existing) return;

                    Task::create([
                        'title' => "Renew {`$doc->type} for {`$doc->club->name}",
                        'description' => "Expiry: {`$doc->expiry_date}. Please refresh details.",
                        'priority' => 'High',
                        'assigned_to_rank' => 'Manager',
                        'status' => 'Pending',
                        'assigner_id' => 1, // System
                    ]);
                });

            // Annual Inspection Reminders
            AnnualInspectionItem::all()->each(function (`$item) {
                `$last = `$item->lastRecord();
                if (`$last && now()->diffInYears(`$last->date) >= `$item->inspection_interval_years) {
                    `$existing = Task::where('title', 'like', "%Annual Inspection for {`$item->name}%")->where('status', 'Pending')->first();
                    if (`$existing) return;

                    Task::create([
                        'title' => "Annual Inspection Overdue for {`$item->name}",
                        'description' => "Last inspection: {`$last->date}. Schedule new.",
                        'priority' => 'High',
                        'assigned_to_rank' => 'Manager',
                        'status' => 'Pending',
                        'assigner_id' => 1,
                    ]);
                }
            });
        })->yearly(); // Or monthly for checks
    }
}
"@

# routes/web.php
Set-Content -Path routes\web.php -Value @"
<?php

// File: routes/web.php (excerpt)

use App\Http\Controllers\SuperAdminController;
use App\Http\Controllers\PoolTestController;
// etc.

Route::middleware(['auth', 'role:SuperAdmin'])->prefix('superadmin')->group(function () {
    Route::get('/dashboard', [SuperAdminController::class, 'dashboard']);
    // Other routes
});

Route::resource('pool-tests', PoolTestController::class)->parameters(['pool-tests' => 'subFacility']);
Route::resource('chemical-stocks', ChemicalStockController::class);
Route::resource('health-checks', HealthCheckController::class)->parameters(['health-checks' => 'subFacility']);
Route::resource('tasks', TaskController::class);

// Add more as needed

use App\Http\Controllers\QualificationController;
use App\Http\Controllers\TrainingSessionController;
use App\Http\Controllers\TrainingAttendanceController;

// ...

Route::resource('qualifications', QualificationController::class);
Route::post('qualifications/{qualification}/assign-required', [QualificationController::class, 'assignRequired']);

Route::resource('training-sessions', TrainingSessionController::class);
Route::get('training/attend/{session}', [TrainingAttendanceController::class, 'attend'])->name('training.attend'); // For QR link

Route::get('training/history/{user}', [TrainingAttendanceController::class, 'individualHistory']);
Route::get('training/stats/team', [TrainingAttendanceController::class, 'teamStats']);

use App\Http\Controllers\WaterMeterReadingController;

// ...

Route::resource('water-meter-readings', WaterMeterReadingController::class)->parameters(['water-meter-readings' => 'subFacility']);
Route::patch('water-meter-readings/{subFacility}/update-normal', [WaterMeterReadingController::class, 'updateNormalUsage'])->name('water-meter-readings.update-normal');

use App\Http\Controllers\BackwashLogController;

// ...

Route::resource('backwash-logs', BackwashLogController::class)->parameters(['backwash-logs' => 'subFacility']);
Route::patch('backwash-logs/{subFacility}/update-interval', [BackwashLogController::class, 'updateInterval'])->name('backwash-logs.update-interval');

use App\Http\Controllers\ExternalHireClubController;
use App\Http\Controllers\AnnualInspectionItemController;

// ...

Route::resource('external-hire-clubs', ExternalHireClubController::class)->parameters(['external-hire-clubs' => 'facility']);
Route::resource('annual-inspection-items', AnnualInspectionItemController::class);
Route::post('annual-inspection-items/{item}/add-record', [AnnualInspectionItemController::class, 'addRecord'])->name('annual-inspection-items.add-record');
"@
```