<?php

// File: database/migrations/0000_00_00_000023_create_annual_inspection_records_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('annual_inspection_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('annual_inspection_item_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->string('inspector_name');
            $table->text('details')->nullable();
            $table->string('certificate_file')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('annual_inspection_records');
    }
};
