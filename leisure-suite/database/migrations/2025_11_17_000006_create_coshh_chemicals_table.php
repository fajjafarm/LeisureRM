<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('coshh_chemicals', function (Blueprint \) {
            \->id();
            \->foreignId('business_id')->constrained()->cascadeOnDelete();
            \->string('name');
            \->string('manufacturer')->nullable();
            \->string('un_number')->nullable();
            \->string('hazard_symbols')->nullable();
            \->decimal('min_stock_level', 10, 2)->default(0);
            \->decimal('current_stock_level', 10, 2)->default(0);
            \->string('storage_location')->nullable();
            \->text('handling_instructions')->nullable();
            \->string('msds_file')->nullable();
            \->timestamps();
            \->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('coshh_chemicals'); }
};
