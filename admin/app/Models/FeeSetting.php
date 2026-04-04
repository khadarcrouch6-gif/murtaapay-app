<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FeeSetting extends Model
{
    protected $fillable = [
        'name',
        'fee_type',
        'fee_value',
        'currency_from',
        'currency_to',
        'min_amount',
        'max_amount',
        'is_active',
        'description',
    ];

    protected $casts = [
        'fee_value'  => 'decimal:4',
        'is_active'  => 'boolean',
        'min_amount' => 'integer',
        'max_amount' => 'integer',
    ];

    /**
     * Calculate fee in cents for a given transaction amount (in cents).
     */
    public function calculateFee(int $amountCents): int
    {
        if ($this->fee_type === 'fixed') {
            return (int) ($this->fee_value * 100); // convert to cents
        }

        return (int) round($amountCents * ($this->fee_value / 100));
    }

    /**
     * Find the applicable fee setting for an amount and currency pair.
     */
    public static function applicableFor(int $amountCents, string $from = 'EUR', string $to = 'USD'): ?self
    {
        return static::where('is_active', true)
            ->where('currency_from', $from)
            ->where('currency_to', $to)
            ->where('min_amount', '<=', $amountCents)
            ->where(function ($q) use ($amountCents) {
                $q->whereNull('max_amount')
                  ->orWhere('max_amount', '>=', $amountCents);
            })
            ->first();
    }
}
