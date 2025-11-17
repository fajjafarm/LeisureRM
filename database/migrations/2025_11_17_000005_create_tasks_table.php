<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint \) {
            \->id();
            \->foreignId('business_id')->constrained()->cascadeOnDelete();
            \->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            \->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            \->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            \->foreignId('created_by')->constrained('users');
            \->string('title');
            \->text('description')->nullable();
            \->enum('priority', ['low','medium','high','critical'])->default('medium');
            \->timestamp('due_at')->nullable();
            \->timestamp('completed_at')->nullable();
            \->foreignId('completed_by')->nullable()->constrained('users')->nullOnDelete();
            \->boolean('is_recurring')->default(false);
            \->json('recurrence_rule')->nullable();
            \->timestamps();
            \->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('tasks'); }
};
