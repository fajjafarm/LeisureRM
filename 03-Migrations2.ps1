# 03-Migrations2.ps1
# # # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# 2025_11_17_000005_create_tasks_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            \$table->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            \$table->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            \$table->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            \$table->foreignId('created_by')->constrained('users');
            \$table->string('title');
            \$table->text('description')->nullable();
            \$table->enum('priority', ['low','medium','high','critical'])->default('medium');
            \$table->timestamp('due_at')->nullable();
            \$table->timestamp('completed_at')->nullable();
            \$table->foreignId('completed_by')->nullable()->constrained('users')->nullOnDelete();
            \$table->boolean('is_recurring')->default(false);
            \$table->json('recurrence_rule')->nullable();
            \$table->timestamps();
            \$table->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('tasks'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000005_create_tasks_table.php"

# 2025_11_17_000006_create_coshh_chemicals_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('coshh_chemicals', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('business_id')->constrained()->cascadeOnDelete();
            \$table->string('name');
            \$table->string('manufacturer')->nullable();
            \$table->string('un_number')->nullable();
            \$table->string('hazard_symbols')->nullable();
            \$table->decimal('min_stock_level', 10, 2)->default(0);
            \$table->decimal('current_stock_level', 10, 2)->default(0);
            \$table->string('storage_location')->nullable();
            \$table->text('handling_instructions')->nullable();
            \$table->string('msds_file')->nullable();
            \$table->timestamps();
            \$table->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('coshh_chemicals'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000006_create_coshh_chemicals_table.php"

# 2025_11_17_000007_create_pool_tests_table.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('pool_tests', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            \$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            \$table->decimal('temperature', 5, 2);
            \$table->decimal('free_chlorine', 5, 2);
            \$table->decimal('total_chlorine', 5, 2)->nullable();
            \$table->decimal('ph', 4, 2);
            \$table->decimal('alkalinity', 6, 2)->nullable();
            \$table->decimal('calcium_hardness', 6, 2)->nullable();
            \$table->decimal('cyanuric_acid', 6, 2)->nullable();
            \$table->boolean('is_out_of_range')->default(false);
            \$table->text('notes')->nullable();
            \$table->timestamp('tested_at')->useCurrent();
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('pool_tests'); }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000007_create_pool_tests_table.php"

# 2025_11_17_000008_create_qualifications_tables.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('qualifications', function (Blueprint \$table) {
            \$table->id();
            \$table->string('name');
            \$table->string('issuing_body')->nullable();
            \$table->integer('validity_months')->default(24);
            \$table->integer('required_training_hours_per_month')->default(2);
            \$table->timestamps();
        });

        Schema::create('user_qualifications', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('user_id')->constrained()->cascadeOnDelete();
            \$table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            \$table->date('awarded_at');
            \$table->date('expires_at')->nullable();
            \$table->string('certificate_file')->nullable();
            \$table->integer('training_hours_logged')->default(0);
            \$table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('user_qualifications');
        Schema::dropIfExists('qualifications');
    }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000008_create_qualifications_tables.php"

# 2025_11_17_000009_create_safety_checklist_tables.php
@"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('safety_checklist_templates', function (Blueprint \$table) {
            \$table->id();
            \$table->string('name');
            \$table->enum('frequency', ['daily','weekly','monthly','quarterly','annual']);
            \$table->integer('days_before_due_alert')->default(7);
            \$table->timestamps();
        });

        Schema::create('safety_checklist_items', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            \$table->string('item_text');
            \$table->boolean('requires_photo')->default(false);
            \$table->boolean('requires_comment_if_no')->default(false);
            \$table->timestamps();
        });

        Schema::create('safety_checklist_completions', function (Blueprint \$table) {
            \$table->id();
            \$table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            \$table->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            \$table->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            \$table->foreignId('completed_by')->constrained('users');
            \$table->date('completion_date');
            \$table->json('responses');
            \$table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('safety_checklist_completions');
        Schema::dropIfExists('safety_checklist_items');
        Schema::dropIfExists('safety_checklist_templates');
    }
};
"@ | Out-File -Encoding utf8 "database/migrations/2025_11_17_000009_create_safety_checklist_tables.php"

Write-Host "03 - Tasks, COSHH, Pool Tests, Qualifications & Safety Checklists migrations created" -ForegroundColor Green
