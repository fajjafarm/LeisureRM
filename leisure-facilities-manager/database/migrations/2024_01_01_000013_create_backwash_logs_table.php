<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('performed_by')->constrained('users');
            $table->timestamp('performed_at');
            $table->integer('duration_minutes')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('backwash_logs');
    }
};
