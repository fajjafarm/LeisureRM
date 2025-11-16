<?php

// File: database/migrations/0000_00_00_000016_create_water_meter_readings_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('water_meter_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->float('reading');
            $table->unique(['sub_facility_id', 'date']); // One per day per sub-facility
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('water_meter_readings');
    }
};
