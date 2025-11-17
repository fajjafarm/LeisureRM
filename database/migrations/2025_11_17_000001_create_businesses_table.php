<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('businesses', function (Blueprint \) {
            \->id();
            \->string('name');
            \->string('slug')->unique();
            \->string('contact_email')->nullable();
            \->string('phone')->nullable();
            \->text('address')->nullable();
            \->json('settings')->nullable();
            \->boolean('is_active')->default(true);
            \->timestamps();
            \->softDeletes();
        });
    }
    public function down(): void { Schema::dropIfExists('businesses'); }
};
