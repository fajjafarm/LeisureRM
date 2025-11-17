<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('coshh_chemicals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('manufacturer')->nullable();
            $table->string('un_number')->nullable();
            $table->string('hazard_symbols')->nullable();
            $table->decimal('min_stock_level', 10, 2)->default(0);
            $table->decimal('current_stock_level', 10, 2)->default(0);
            $table->string('storage_location')->nullable();
            $table->text('handling_instructions')->nullable();
            $table->string('msds_file')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coshh_chemicals');
    }
};
