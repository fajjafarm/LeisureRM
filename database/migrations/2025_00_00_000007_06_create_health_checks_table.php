<?php

// File: database/migrations/0000_00_00_000006_create_health_checks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('health_checks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamp('checked_at')->useCurrent();
            $table->text('notes')->nullable();
            $table->enum('status', ['Passed', 'Failed', 'Maintenance']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('health_checks');
    }
};
