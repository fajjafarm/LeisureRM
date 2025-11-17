<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('daily_overviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->date('overview_date')->unique()->default(DB::raw('CURRENT_DATE'));
            $table->integer('expected_guests')->default(0);
            $table->text('classes_today')->nullable();
            $table->text('special_events')->nullable();
            $table->text('notes')->nullable();
            $table->json('staff_on_shift')->nullable(); // [{"user_id":1,"start":"08:00","end":"16:00","break":"30"}]
            $table->timestamps();
        });

        Schema::create('message_board_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('message');
            $table->boolean('pinned')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('message_board_posts');
        Schema::dropIfExists('daily_overviews');
    }
};
