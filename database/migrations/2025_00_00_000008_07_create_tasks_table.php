<?php

// File: database/migrations/0000_00_00_000007_create_tasks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->datetime('due_date')->nullable();
            $table->enum('priority', ['Low', 'Medium', 'High']);
            $table->foreignId('assigned_to_user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->enum('assigned_to_rank', ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant'])->nullable();
            $table->enum('status', ['Pending', 'In Progress', 'Completed'])->default('Pending');
            $table->foreignId('assigner_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
