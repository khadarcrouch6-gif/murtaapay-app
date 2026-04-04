<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    protected $fillable = [
        'user_id',
        'currency',
        'balance',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    /**
     * Get balance in human-readable format (e.g. 10.50)
     */
    public function getFormattedBalanceAttribute()
    {
        return number_format($this->balance / 100, 2);
    }
}
