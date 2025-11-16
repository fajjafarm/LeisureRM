<?php

// File: database/migrations/0000_00_00_000022_create_annual_inspection_items_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('annual_inspection_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->nullable()->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->integer('inspection_interval_years')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('annual_inspection_items');
    }
};
