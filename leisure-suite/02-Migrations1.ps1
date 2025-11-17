# 02-Migrations1.ps1
# # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

$timestamp = Get-Date -Format "yyyy_MM_dd_HHmmss"

# 2024_11_17_000001_create_businesses_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('businesses', function (Blueprint \$table) {
            \$table->id();
            \$table->string('name');
            \$table->string('slug')->unique();
            \$table->string('contact_email')->nullable();
            \$table->string('phone')->nullable();
            \$table->text('address')->nullable();
            \$table->json('settings')->nullable();
            \$table->boolean('is_active')->default(true);
            \$table->timestamps();
            \$table->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('businesses'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000001_create_businesses_table.php"

# 2024_11_17_000002_create_facilities_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('facilities', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            \$table->string('name');
            \$table->string('slug')->unique();
            \$table->text('address')->nullable();
            \$table->string('postcode')->nullable();
            \$table->boolean('is_active')->default(true);
            \$table->timestamps();
            \$table->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('facilities'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000002_create_facilities_table.php"

# 2024_11_17_000003_create_sub_facilities_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('sub_facilities', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            \$table->string('name');
            \$table->string('type'); // pool, sauna, hot_tub, soft_play etc.
            \$table->boolean('is_thermal_suite')->default(false);
            \$table->integer('check_interval_minutes')->nullable();
            \$table->timestamp('last_checked_at')->nullable();
            \$table->json('parameters')->nullable();
            \$table->boolean('requires_backwash')->default(false);
            \$table->integer('max_backwash_days')->nullable();
            \$table->timestamp('last_backwash_at')->nullable();
            \$table->timestamps();
            \$table->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('sub_facilities'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000003_create_sub_facilities_table.php"

# 2024_11_17_000004_create_user_profiles_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            \$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            \$table->foreignId('current_facility_id')->nullable()->constrained('facilities');
            \$table->date('start_date')->nullable();
            \$table->date('end_date')->nullable();
            \$table->integer('required_training_hours_per_month')->default(2);
            \$table->integer('training_hours_this_month')->default(0);
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('user_profiles'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000004_create_user_profiles_table.php"

Write-Host "02 - Core tenancy migrations created (Business → Facility → SubFacility → UserProfile)" -ForegroundColor Green
