<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fee_settings', function (Blueprint $table) {
            $table->id();
            $table->string('name');                                   // e.g. "Standard Send Fee"
            $table->enum('fee_type', ['fixed', 'percent'])->default('percent');
            $table->decimal('fee_value', 10, 4);                     // e.g. 1.50 (%)  or 200 (cents)
            $table->string('currency_from', 3)->default('EUR');
            $table->string('currency_to', 3)->default('USD');
            $table->bigInteger('min_amount')->default(0);            // minimum transaction in cents
            $table->bigInteger('max_amount')->nullable();            // null = no upper limit
            $table->boolean('is_active')->default(true);
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fee_settings');
    }
};
