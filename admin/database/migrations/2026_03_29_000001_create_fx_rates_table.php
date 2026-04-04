<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fx_rates', function (Blueprint $table) {
            $table->id();
            $table->string('currency_from', 3)->default('EUR');
            $table->string('currency_to', 3)->default('USD');
            $table->decimal('rate', 12, 6);                    // e.g. 1.0850
            $table->decimal('spread_percent', 5, 2)->default(0.00); // e.g. 1.50%
            $table->boolean('is_active')->default(false);
            $table->enum('source', ['manual', 'api'])->default('manual');
            $table->string('api_provider')->nullable();         // e.g. "exchangerate-api"
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['currency_from', 'currency_to', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fx_rates');
    }
};
