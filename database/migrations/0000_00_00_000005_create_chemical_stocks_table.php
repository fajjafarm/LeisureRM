<?php

// File: database/migrations/0000_00_00_000005_create_chemical_stocks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chemical_stocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->nullable()->constrained()->cascadeOnDelete();
            $table->string('chemical_name');
            $table->float('quantity');
            $table->string('unit');
            $table->float('min_threshold');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chemical_stocks');
    }
};
