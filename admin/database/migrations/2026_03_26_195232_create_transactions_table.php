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
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('wallet_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['add', 'send', 'withdraw', 'transfer', 'referral_bonus']);
            $table->bigInteger('amount'); // Amount in cents
            $table->bigInteger('fee')->default(0); // Fee in cents
            $table->string('currency', 3);
            $table->enum('status', ['pending', 'completed', 'failed', 'rejected'])->default('pending');
            $table->string('reference')->unique();
            $table->string('payment_method')->nullable(); // zaad, evc, edahab, bank
            $table->string('recipient_identifier')->nullable(); // phone number or wallet id
            $table->text('description')->nullable();
            $table->json('metadata')->nullable(); // For additional info
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
