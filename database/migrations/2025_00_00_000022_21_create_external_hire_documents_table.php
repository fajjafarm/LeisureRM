<?php

// File: database/migrations/0000_00_00_000021_create_external_hire_documents_table.php (New Migration)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('external_hire_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('external_hire_club_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['qualification', 'insurance']);
            $table->string('file_path');
            $table->date('expiry_date')->nullable();
            $table->boolean('is_current')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('external_hire_documents');
    }
};
