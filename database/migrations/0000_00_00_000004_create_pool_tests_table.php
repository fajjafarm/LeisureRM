<?php

// File: database/migrations/2025_11_16_000004_create_pool_tests_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Ensure the users table exists before creating pool_tests
        if (!Schema::hasTable('users')) {
            throw new \Exception('The users table must be created before the pool_tests table.');
        }

        Schema::create('pool_tests', function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('tested_at')->useCurrent();
            $table->float('temperature');
            $table->float('ph');
            $table->float('chlorine');
            $table->float('alkalinity');
            $table->float('calcium_hardness');
            $table->float('tds')->nullable();
            $table->float('balance_result');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pool_tests');
    }
};