<?php

// File: database/migrations/0000_00_00_000018_create_backwash_logs_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->datetime('date');
            $table->integer('duration_minutes')->default(0);
            $table->float('water_used')->default(0); // e.g., in liters or gallons
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('backwash_logs');
    }
};
