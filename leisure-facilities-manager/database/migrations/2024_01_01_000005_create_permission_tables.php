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
