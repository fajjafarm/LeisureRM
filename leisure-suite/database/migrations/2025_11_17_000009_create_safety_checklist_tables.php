<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('safety_checklist_templates', function (Blueprint \) {
            \->id();
            \->string('name');
            \->enum('frequency', ['daily','weekly','monthly','quarterly','annual']);
            \->integer('days_before_due_alert')->default(7);
            \->timestamps();
        });

        Schema::create('safety_checklist_items', function (Blueprint \) {
            \->id();
            \->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            \->string('item_text');
            \->boolean('requires_photo')->default(false);
            \->boolean('requires_comment_if_no')->default(false);
            \->timestamps();
        });

        Schema::create('safety_checklist_completions', function (Blueprint \) {
            \->id();
            \->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            \->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            \->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            \->foreignId('completed_by')->constrained('users');
            \->date('completion_date');
            \->json('responses');
            \->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('safety_checklist_completions');
        Schema::dropIfExists('safety_checklist_items');
        Schema::dropIfExists('safety_checklist_templates');
    }
};
