<?php

// File: database/migrations/0000_00_00_000017_add_normal_daily_usage_to_sub_facilities.php (New Migration for update)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sub_facilities', function (Blueprint $table) {
            $table->float('normal_daily_usage')->default(0)->after('check_end_time');
        });
    }

    public function down(): void
    {
        Schema::table('sub_facilities', function (Blueprint $table) {
            $table->dropColumn('normal_daily_usage');
        });
    }
};
