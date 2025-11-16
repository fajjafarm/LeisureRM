<?php

// File: database/migrations/0000_00_00_000004_create_pool_tests_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pool_tests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
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
