<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FxRate extends Model
{
    protected $fillable = [
        'currency_from',
        'currency_to',
        'rate',
        'spread_percent',
        'is_active',
        'source',
        'api_provider',
        'created_by',
    ];

    protected $casts = [
        'rate'           => 'decimal:6',
        'spread_percent' => 'decimal:2',
        'is_active'      => 'boolean',
    ];

    /** The effective rate after applying the spread */
    public function getEffectiveRateAttribute(): float
    {
        return round($this->rate * (1 - $this->spread_percent / 100), 6);
    }

    /** Returns the currently active rate */
    public static function activeRate(string $from = 'EUR', string $to = 'USD'): ?self
    {
        return static::where('currency_from', $from)
            ->where('currency_to', $to)
            ->where('is_active', true)
            ->latest()
            ->first();
    }

    /** Convert an amount using this rate */
    public function convert(int $amountCents): int
    {
        return (int) round($amountCents * $this->effective_rate);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
