<?php

// File: database/migrations/0000_00_00_000015_create_training_attendances_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('training_attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('training_session_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->datetime('attended_at')->useCurrent();
            $table->float('score')->nullable(); // For CPR
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('training_attendances');
    }
};
