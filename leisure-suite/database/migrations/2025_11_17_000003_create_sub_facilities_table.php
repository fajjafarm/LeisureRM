<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('sub_facilities', function (Blueprint \) {
            \->id();
            \->foreignId('facility_id')->constrained()->cascadeOnDelete();
            \->string('name');
            \->string('type'); // pool, sauna, hot_tub, soft_play etc.
            \->boolean('is_thermal_suite')->default(false);
            \->integer('check_interval_minutes')->nullable();
            \->timestamp('last_checked_at')->nullable();
            \->json('parameters')->nullable();
            \->boolean('requires_backwash')->default(false);
            \->integer('max_backwash_days')->nullable();
            \->timestamp('last_backwash_at')->nullable();
            \->timestamps();
            \->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('sub_facilities'); }
};
