<?php

// File: database/migrations/0000_00_00_000019_add_backwash_interval_to_sub_facilities.php (New Migration for update)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sub_facilities', function (Blueprint $table) {
            $table->integer('backwash_interval_days')->default(7)->after('normal_daily_usage'); // e.g., weekly
        });
    }

    public function down(): void
    {
        Schema::table('sub_facilities', function (Blueprint $table) {
            $table->dropColumn('backwash_interval_days');
        });
    }
};
