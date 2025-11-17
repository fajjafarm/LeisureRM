# 03-Migrations-Part2.ps1
Set-Location leisure-facilities-manager

# 2024_01_01_000005_create_permission_tables.php (Spatie)
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Spatie\Permission\PermissionRegistrar;

return new class extends Migration {
    public function up(): void
    {
        $tables = config('permission.table_names');

        \Illuminate\Support\Facades\Schema::create($tables['permissions'], function (\Illuminate\Database\Schema\Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name');
            $table->string('guard_name');
            $table->string('module')->nullable(); // e.g. COSHH, Pool Testing
            $table->timestamps();

            $table->unique(['name', 'guard_name']);
        });

        \Illuminate\Support\Facades\Schema::create($tables['roles'], function (\Illuminate\Database\Schema\Blueprint $table) use ($tables) {
            $table->bigIncrements('id');
            $table->string('name');
            $table->string('guard_name');
            $table->foreignId('business_id')->nullable()->constrained()->nullOnDelete();
            $table->boolean('is_system_role')->default(false);
            $table->timestamps();

            $table->unique(['name', 'guard_name', 'business_id']);
        });

        \Illuminate\Support\Facades\Schema::create($tables['model_has_permissions'], function (\Illuminate\Database\Schema\Blueprint $table) use ($tables) {
            $table->unsignedBigInteger('permission_id');
            $table->morphs('model');

            $table->foreign('permission_id')
                  ->references('id')
                  ->on($tables['permissions'])
                  ->onDelete('cascade');

            $table->primary(['permission_id', 'model_id', 'model_type']);
        });

        \Illuminate\Support\Facades\Schema::create($tables['model_has_roles'], function (\Illuminate\Database\Schema\Blueprint $table) use ($tables) {
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->morphs('model');
            $table->foreignId('business_id')->constrained()->cascadeOnDelete();

            $table->primary(['role_id', 'model_id', 'model_type']);
        });

        \Illuminate\Support\Facades\Schema::create($tables['role_has_permissions'], function (\Illuminate\Database\Schema\Blueprint $table) use ($tables) {
            $table->foreignId('permission_id')->constrained()->cascadeOnDelete();
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();

            $table->primary(['permission_id', 'role_id']);
        });
    }

    public function down(): void
    {
        $tables = config('permission.table_names');
        foreach ($tables as $table) {
            \Illuminate\Support\Facades\Schema::dropIfExists($table);
        }
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000005_create_permission_tables.php

# 2024_01_01_000006_create_tasks_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            $table->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('priority', ['low', 'medium', 'high', 'critical'])->default('medium');
            $table->timestamp('due_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->foreignId('completed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('is_recurring')->default(false);
            $table->json('recurrence_rule')->nullable(); // RRULE format
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000006_create_tasks_table.php

# 2024_01_01_000007_create_coshh_chemicals_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('coshh_chemicals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('manufacturer')->nullable();
            $table->string('un_number')->nullable();
            $table->string('hazard_symbols')->nullable();
            $table->decimal('min_stock_level', 10, 2)->default(0);
            $table->decimal('current_stock_level', 10, 2)->default(0);
            $table->string('storage_location')->nullable();
            $table->text('handling_instructions')->nullable();
            $table->string('msds_file')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coshh_chemicals');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000007_create_coshh_chemicals_table.php

# 2024_01_01_000008_create_pool_tests_table.php
@'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('pool_tests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->decimal('temperature', 5, 2);
            $table->decimal('free_chlorine', 5, 2);
            $table->decimal('total_chlorine', 5, 2)->nullable();
            $table->decimal('ph', 4, 2);
            $table->decimal('alkalinity', 6, 2)->nullable();
            $table->decimal('calcium_hardness', 6, 2)->nullable();
            $table->decimal('cyanuric_acid', 6, 2)->nullable();
            $table->boolean('is_out_of_range')->default(false);
            $table->text('notes')->nullable();
            $table->timestamp('tested_at')->useCurrent();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pool_tests');
    }
};
'@ | Out-File -Encoding utf8 database\migrations\2024_01_01_000008_create_pool_tests_table.php

Write-Host "03 - Permissions, Tasks, COSHH, Pool Tests migrations created"