# 04-Migrations-Part3.ps1
Set-Location leisure-facilities-manager

# 2024_01_01_000009_create_water_meter_readings_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('water_meter_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->string('meter_location');
            $table->decimal('reading', 12, 2);
            $table->date('reading_date');
            $table->foreignId('recorded_by')->constrained('users');
            $table->timestamps();

            $table->unique(['facility_id', 'meter_location', 'reading_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('water_meter_readings');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000009_create_water_meter_readings_table.php

# 2024_01_01_000010_create_qualifications_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('qualifications', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. NPLQ, First Aid at Work
            $table->string('issuing_body')->nullable();
            $table->integer('validity_months')->default(24);
            $table->integer('required_training_hours_per_month')->default(2);
            $table->timestamps();
        });

        Schema::create('user_qualifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            $table->date('awarded_at');
            $table->date('expires_at')->nullable();
            $table->string('certificate_file')->nullable();
            $table->integer('training_hours_logged')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_qualifications');
        Schema::dropIfExists('qualifications');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000010_create_qualifications_table.php

# 2024_01_01_000011_create_club_hires_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('club_hires', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->string('club_name');
            $table->string('contact_name');
            $table->string('contact_phone');
            $table->string('contact_email');
            $table->string('safeguarding_lead')->nullable();
            $table->string('insurance_provider')->nullable();
            $table->string('insurance_policy_number')->nullable();
            $table->date('insurance_expiry');
            $table->string('insurance_document')->nullable();
            $table->date('qualification_expiry')->nullable();
            $table->string('qualification_document')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('club_hires');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000011_create_club_hires_table.php

# 2024_01_01_000012_create_safety_checklists_and_items.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('safety_checklist_templates', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. Daily Pool Safety Check, Monthly Soft Play Inspection
            $table->enum('frequency', ['daily','weekly','monthly','quarterly','annual']);
            $table->integer('days_before_due_alert')->default(7);
            $table->timestamps();
        });

        Schema::create('safety_checklist_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            $table->string('item_text');
            $table->boolean('requires_photo')->default(false);
            $table->boolean('requires_comment_if_no')->default(false);
            $table->timestamps();
        });

        Schema::create('safety_checklist_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            $table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            $table->foreignId('completed_by')->constrained('users');
            $table->date('completion_date');
            $table->json('responses'); // stores item_id => ['pass'=>bool, 'comment'=>text, 'photo'=>path]
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('safety_checklist_completions');
        Schema::dropIfExists('safety_checklist_items');
        Schema::dropIfExists('safety_checklist_templates');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000012_create_safety_checklists_and_items.php

# 2024_01_01_000013_create_backwash_logs_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('performed_by')->constrained('users');
            $table->timestamp('performed_at');
            $table->integer('duration_minutes')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('backwash_logs');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000013_create_backwash_logs_table.php

# 2024_01_01_000014_create_message_board_posts_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('daily_overviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->date('overview_date')->unique()->default(DB::raw('CURRENT_DATE'));
            $table->integer('expected_guests')->default(0);
            $table->text('classes_today')->nullable();
            $table->text('special_events')->nullable();
            $table->text('notes')->nullable();
            $table->json('staff_on_shift')->nullable(); // [{"user_id":1,"start":"08:00","end":"16:00","break":"30"}]
            $table->timestamps();
        });

        Schema::create('message_board_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('message');
            $table->boolean('pinned')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('message_board_posts');
        Schema::dropIfExists('daily_overviews');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000014_create_message_board_posts_table.php

Write-Host "04 - All remaining core migrations completed (Water Meters, Qualifications, Club Hire, Safety Checklists, Backwash, Message Board)"