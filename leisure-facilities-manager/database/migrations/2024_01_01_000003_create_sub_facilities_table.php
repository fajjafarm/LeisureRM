<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('sub_facilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('type'); // pool, baby_pool, sauna, steam_room, soft_play etc.
            $table->boolean('is_thermal_suite')->default(false);
            $table->integer('check_interval_minutes')->nullable(); // e.g. 20 for sauna
            $table->timestamp('last_checked_at')->nullable();
            $table->json('parameters')->nullable(); // length, width, depth, target temp, chlorine etc.
            $table->boolean('requires_backwash')->default(false);
            $table->integer('max_backwash_days')->nullable();
            $table->timestamp('last_backwash_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sub_facilities');
    }
};
