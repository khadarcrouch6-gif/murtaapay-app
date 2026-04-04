<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('float_accounts', function (Blueprint $table) {
            $table->id();
            $table->string('name');                               // e.g. "Wallester EUR Account"
            $table->enum('provider', ['wallester', 'waafi', 'edahab', 'evcplus', 'other']);
            $table->string('currency', 3);
            $table->bigInteger('balance')->default(0);            // in cents
            $table->bigInteger('alert_threshold')->default(100000); // 1000.00 in cents — trigger alert
            $table->string('account_identifier')->nullable();     // Wallester account ID or WAAFI phone
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('float_accounts');
    }
};
