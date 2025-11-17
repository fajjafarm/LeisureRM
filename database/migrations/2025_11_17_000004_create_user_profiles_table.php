<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint \) {
            \->id();
            \->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            \->foreignId('business_id')->constrained()->cascadeOnDelete();
            \->foreignId('current_facility_id')->nullable()->constrained('facilities');
            \->date('start_date')->nullable();
            \->date('end_date')->nullable();
            \->integer('required_training_hours_per_month')->default(2);
            \->integer('training_hours_this_month')->default(0);
            \->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('user_profiles'); }
};
