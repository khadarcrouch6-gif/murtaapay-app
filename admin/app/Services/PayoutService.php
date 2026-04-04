<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use App\Models\FloatAccount;

class PayoutService
{
    /**
     * Initiate a payout using WAAFI.
     */
    public function initiateWaafiPayout(string $phone, int $amountUsdCents, string $reference): array
    {
        $amountUsd = $amountUsdCents / 100;
        Log::info("Initiating WAAFI Payout: Send $amountUsd USD to $phone [Ref: $reference]");

        // Simulate API check for float/liquidity
        $float = FloatAccount::where('provider', 'waafi')->where('currency', 'USD')->first();
        if ($float && $float->balance < $amountUsdCents) {
            Log::error("WAAFI Payout Failed: Insufficient Float Balance ($float->balance)");
            return ['success' => false, 'error' => 'Insufficient float balance'];
        }

        // TODO: Real WAAFI API Implementation
        // Simulation delay if needed
        
        return [
            'success'     => true,
            'transfer_id' => 'WF-' . strtoupper(Str::random(12)),
            'provider'    => 'waafi',
            'amount_usd'  => $amountUsd,
            'fee_usd'     => 0, // Placeholder
        ];
    }

    /**
     * Initiate a payout using e-Dahab.
     */
    public function initiateEdahabPayout(string $phone, int $amountUsdCents, string $reference): array
    {
        $amountUsd = $amountUsdCents / 100;
        Log::info("Initiating e-Dahab Payout: Send $amountUsd USD to $phone [Ref: $reference]");

        // Simulate API check for float/liquidity
        $float = FloatAccount::where('provider', 'edahab')->where('currency', 'USD')->first();
        if ($float && $float->balance < $amountUsdCents) {
            Log::error("e-Dahab Payout Failed: Insufficient Float Balance ($float->balance)");
            return ['success' => false, 'error' => 'Insufficient float balance'];
        }

        // TODO: Real e-Dahab API Implementation
        
        return [
            'success'     => true,
            'transfer_id' => 'ED-' . strtoupper(Str::random(12)),
            'provider'    => 'edahab',
            'amount_usd'  => $amountUsd,
        ];
    }

    /**
     * Determine the best payout provider for a specific phone number/region.
     */
    public function resolveProvider(string $phone): string
    {
        // Simple logic for Somalia prefixes for now
        if (Str::startsWith($phone, ['+25261', '25261', '61'])) {
            return 'waafi'; // Hormuud
        }
        
        if (Str::startsWith($phone, ['+25262', '25262', '62'])) {
            return 'edahab'; // Dahabshiil
        }
        
        return 'waafi'; // Default
    }
}
