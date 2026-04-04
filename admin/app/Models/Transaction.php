<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'user_id',
        'wallet_id',
        'type',
        'amount',
        'fee',
        'currency',
        'status',
        'reference',
        'payment_method',
        'recipient_identifier',
        'description',
        'metadata',
        // Bridge columns
        'wallester_charge_id',
        'waafi_transfer_id',
        'exchange_rate',
        'fee_amount',
        'net_amount',
        'refund_status',
    ];

    protected $casts = [
        'metadata'      => 'array',
        'exchange_rate' => 'decimal:6',
        'amount'        => 'integer',
        'fee'           => 'integer',
        'fee_amount'    => 'integer',
        'net_amount'    => 'integer',
    ];

    /** Amount formatted in given currency */
    public function getFormattedAmountAttribute(): string
    {
        return $this->currency . ' ' . number_format($this->amount / 100, 2);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }
}
