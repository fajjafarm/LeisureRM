<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('facilities', function (Blueprint \) {
            \->id();
            \->foreignId('business_id')->constrained()->cascadeOnDelete();
            \->string('name');
            \->string('slug')->unique();
            \->text('address')->nullable();
            \->string('postcode')->nullable();
            \->boolean('is_active')->default(true);
            \->timestamps();
            \->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('facilities'); }
};
