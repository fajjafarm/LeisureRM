<?php

// File: database/migrations/0000_00_00_000014_create_training_sessions_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('training_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->datetime('date');
            $table->string('type'); // e.g., 'CPR'
            $table->float('duration_hours')->default(0);
            $table->text('qr_code')->nullable();
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('training_sessions');
    }
};
