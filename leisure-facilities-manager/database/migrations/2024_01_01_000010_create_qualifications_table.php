<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('qualifications', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. NPLQ, First Aid at Work
            $table->string('issuing_body')->nullable();
            $table->integer('validity_months')->default(24);
            $table->integer('required_training_hours_per_month')->default(2);
            $table->timestamps();
        });

        Schema::create('user_qualifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('qualification_id')->constrained()->cascadeOnDelete();
            $table->date('awarded_at');
            $table->date('expires_at')->nullable();
            $table->string('certificate_file')->nullable();
            $table->integer('training_hours_logged')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_qualifications');
        Schema::dropIfExists('qualifications');
    }
};
