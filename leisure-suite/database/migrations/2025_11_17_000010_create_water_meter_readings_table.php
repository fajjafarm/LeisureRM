<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('water_meter_readings', function (Blueprint \) {
            \->id();
            \->foreignId('facility_id')->constrained()->cascadeOnDelete();
            \->string('meter_location');
            \->decimal('reading', 12, 2);
            \->date('reading_date');
            \->foreignId('recorded_by')->constrained('users');
            \->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('water_meter_readings'); }
};
