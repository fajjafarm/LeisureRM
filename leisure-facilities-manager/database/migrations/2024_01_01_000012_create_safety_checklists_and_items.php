<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('safety_checklist_templates', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. Daily Pool Safety Check, Monthly Soft Play Inspection
            $table->enum('frequency', ['daily','weekly','monthly','quarterly','annual']);
            $table->integer('days_before_due_alert')->default(7);
            $table->timestamps();
        });

        Schema::create('safety_checklist_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            $table->string('item_text');
            $table->boolean('requires_photo')->default(false);
            $table->boolean('requires_comment_if_no')->default(false);
            $table->timestamps();
        });

        Schema::create('safety_checklist_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('sub_facility_id')->nullable()->constrained('sub_facilities')->nullOnDelete();
            $table->foreignId('template_id')->constrained('safety_checklist_templates')->cascadeOnDelete();
            $table->foreignId('completed_by')->constrained('users');
            $table->date('completion_date');
            $table->json('responses'); // stores item_id => ['pass'=>bool, 'comment'=>text, 'photo'=>path]
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('safety_checklist_completions');
        Schema::dropIfExists('safety_checklist_items');
        Schema::dropIfExists('safety_checklist_templates');
    }
};
