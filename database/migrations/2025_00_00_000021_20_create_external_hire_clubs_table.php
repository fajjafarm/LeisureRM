<?php

// File: database/migrations/0000_00_00_000020_create_external_hire_clubs_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('external_hire_clubs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->json('contact_details')->nullable();
            $table->string('safeguarding_contact')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('external_hire_clubs');
    }
};
