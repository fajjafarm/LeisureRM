<?php

// File: database/migrations/0000_00_00_000003_create_sub_facilities_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sub_facilities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->integer('check_interval_minutes')->default(120);
            $table->time('check_start_time')->default('08:00');
            $table->time('check_end_time')->default('20:00');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sub_facilities');
    }
};
