<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->string('wallester_charge_id')->nullable()->after('reference');
            $table->string('waafi_transfer_id')->nullable()->after('wallester_charge_id');
            $table->decimal('exchange_rate', 12, 6)->nullable()->after('currency');
            $table->bigInteger('fee_amount')->default(0)->after('exchange_rate');   // fee in cents
            $table->bigInteger('net_amount')->nullable()->after('fee_amount');       // after fee + FX
            $table->enum('refund_status', ['none', 'requested', 'refunded'])->default('none')->after('status');

            $table->index('wallester_charge_id');
            $table->index('waafi_transfer_id');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn([
                'wallester_charge_id',
                'waafi_transfer_id',
                'exchange_rate',
                'fee_amount',
                'net_amount',
                'refund_status',
            ]);
        });
    }
};
