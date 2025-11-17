<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('qualifications', function (Blueprint \) {
            \->id();
            \->string('name');
            \->string('issuing_body')->nullable();
            \->integer('validity_months')->default(24);
            \->integer('required_training_hours_per_month')->default(2);
            \->timestamps();
        });

        Schema::create('user_qualifications', function (Blueprint \) {
            \->id();
            \->foreignId('user_id')->constrained()->cascadeOnDelete();
            \->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            \->date('awarded_at');
            \->date('expires_at')->nullable();
            \->string('certificate_file')->nullable();
            \->integer('training_hours_logged')->default(0);
            \->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('user_qualifications');
        Schema::dropIfExists('qualifications');
    }
};
