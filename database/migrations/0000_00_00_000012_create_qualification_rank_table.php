<?php

// File: database/migrations/0000_00_00_000012_create_qualification_rank_table.php (Pivot for required per rank)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('qualification_rank', function (Blueprint $table) {
            $table->id();
            $table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            $table->enum('rank', ['Manager', 'Deputy Manager', 'Assistant Manager', 'Supervisor', 'Assistant']);
            $table->boolean('required')->default(true);
            $table->unique(['qualification_id', 'rank']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('qualification_rank');
    }
};
