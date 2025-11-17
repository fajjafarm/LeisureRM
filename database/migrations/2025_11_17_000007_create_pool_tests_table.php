<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('pool_tests', function (Blueprint \) {
            \->id();
            \->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            \->foreignId('user_id')->constrained()->cascadeOnDelete();
            \->decimal('temperature', 5, 2);
            \->decimal('free_chlorine', 5, 2);
            \->decimal('total_chlorine', 5, 2)->nullable();
            \->decimal('ph', 4, 2);
            \->decimal('alkalinity', 6, 2)->nullable();
            \->decimal('calcium_hardness', 6, 2)->nullable();
            \->decimal('cyanuric_acid', 6, 2)->nullable();
            \->boolean('is_out_of_range')->default(false);
            \->text('notes')->nullable();
            \->timestamp('tested_at')->useCurrent();
            \->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('pool_tests'); }
};
