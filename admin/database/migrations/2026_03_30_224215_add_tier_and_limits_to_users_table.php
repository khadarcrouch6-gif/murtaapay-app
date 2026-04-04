<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('tier')->default('basic')->after('status'); // basic, silver, gold
            $table->unsignedBigInteger('daily_limit')->default(100000)->after('tier'); // cents ($1000)
            $table->unsignedBigInteger('monthly_limit')->default(500000)->after('daily_limit'); // cents ($5000)
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['tier', 'daily_limit', 'monthly_limit']);
        });
    }
};
