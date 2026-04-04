<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FloatAccount extends Model
{
    protected $fillable = [
        'name',
        'provider',
        'currency',
        'balance',
        'alert_threshold',
        'account_identifier',
        'is_active',
        'last_synced_at',
    ];

    protected $casts = [
        'balance'          => 'integer',
        'alert_threshold'  => 'integer',
        'is_active'        => 'boolean',
        'last_synced_at'   => 'datetime',
    ];

    /** Balance in human-readable decimal format */
    public function getBalanceFormattedAttribute(): string
    {
        return number_format($this->balance / 100, 2);
    }

    /** True when balance is at or below the alert threshold */
    public function getIsLowAttribute(): bool
    {
        return $this->balance <= $this->alert_threshold;
    }

    /** Percentage of threshold remaining (for progress bars) */
    public function getThresholdPercentAttribute(): int
    {
        if ($this->alert_threshold === 0) {
            return 100;
        }
        return (int) min(100, round(($this->balance / ($this->alert_threshold * 3)) * 100));
    }
}
