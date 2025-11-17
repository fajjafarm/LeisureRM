<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('backwash_logs', function (Blueprint \) {
            \->id();
            \->foreignId('sub_facility_id')->constrained()->cascadeOnDelete();
            \->foreignId('performed_by')->constrained('users');
            \->timestamp('performed_at');
            \->integer('duration_minutes')->nullable();
            \->text('notes')->nullable();
            \->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('backwash_logs'); }
};
