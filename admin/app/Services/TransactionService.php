<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\FxRate;
use App\Models\FeeSetting;
use App\Models\FloatAccount;
use App\Models\ActivityLog;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class TransactionService
{
    /**
     * Complete a remittance bridge (The Bridge).
     * This method is the core ledger that connects Wallester pay-in to WAAFI/e-Dahab pay-out.
     */
    public function processRemittanceBridge(array $data): Transaction
    {
        return DB::transaction(function () use ($data) {
            $amountEurCents = $data['amount_cents'];
            $userId         = $data['user_id'];
            $recipient      = $data['recipient_phone'];
            $chargeId       = $data['charge_id'];

            // 1. Get active FX rate and fee
            $fxRate    = FxRate::activeRate('EUR', 'USD');
            $feeSetting = FeeSetting::applicableFor($amountEurCents, 'EUR', 'USD');

            if (!$fxRate) {
                throw new \Exception('No active FX rate found for EUR→USD');
            }

            // 2. Calculate amounts
            $feeAmountCents = $feeSetting ? $feeSetting->calculateFee($amountEurCents) : 0;
            $netEurCents    = $amountEurCents - $feeAmountCents;
            $netUsdCents    = $fxRate->convert($netEurCents);

            // 3. Create the transaction record
            $transaction = Transaction::create([
                'user_id'              => $userId,
                'wallet_id'            => Wallet::where('user_id', $userId)->where('currency', 'EUR')->first()?->id,
                'type'                 => 'send',
                'amount'               => $amountEurCents,
                'fee'                  => $feeAmountCents,
                'fee_amount'           => $feeAmountCents,
                'net_amount'           => $netUsdCents,
                'currency'             => 'EUR',
                'exchange_rate'        => $fxRate->effective_rate,
                'status'               => 'pending',
                'reference'            => 'TX-' . strtoupper(Str::random(10)),
                'wallester_charge_id'  => $chargeId,
                'payment_method'       => 'wallester_card',
                'recipient_identifier' => $recipient,
                'description'          => "Send $" . number_format($netUsdCents / 100, 2) . " USD via Payout Provider",
            ]);

            // 4. Resolve and Trigger Payout
            $payoutService = app(PayoutService::class);
            $provider      = $payoutService->resolveProvider($recipient);
            
            $payoutResult  = match ($provider) {
                'edahab' => $payoutService->initiateEdahabPayout($recipient, $netUsdCents, $transaction->reference),
                default  => $payoutService->initiateWaafiPayout($recipient, $netUsdCents, $transaction->reference),
            };

            if ($payoutResult['success']) {
                $transaction->update([
                    'status'            => 'completed',
                    'waafi_transfer_id' => $payoutResult['transfer_id'], // Using this generically for now or using a separate column
                ]);
                
                // Update Float Balances
                $this->updateFloatBalances($amountEurCents, $netUsdCents, $provider);
                
                // Audit Log
                ActivityLog::record('remittance_completed', $transaction, [], [
                    'amount_eur' => $amountEurCents / 100,
                    'amount_usd' => $netUsdCents / 100,
                    'provider'   => $provider
                ]);
            } else {
                $transaction->update(['status' => 'failed']);
                Log::error("Payout failed for transaction $transaction->reference: " . $payoutResult['error']);
                
                ActivityLog::record('remittance_failed', $transaction, [], ['error' => $payoutResult['error']]);
            }

            return $transaction;
        });
    }

    /**
     * Update float balances after a successful transaction.
     */
    protected function updateFloatBalances(int $eurAmountCents, int $usdAmountCents, string $payoutProvider): void
    {
        // 1. Increment Wallester (Pay-in) Float (we now have these Euros in our Wallester account)
        FloatAccount::where('provider', 'wallester')->where('currency', 'EUR')
            ->increment('balance', $eurAmountCents);

        // 2. Decrement Payout (Pay-out) Float (we just spent these Dollars via the provider)
        FloatAccount::where('provider', $payoutProvider)->where('currency', 'USD')
            ->decrement('balance', $usdAmountCents);
            
        // Check for low balance triggers
        $this->checkLowBalance($payoutProvider);
    }

    /**
     * Internal check for low float balances.
     */
    protected function checkLowBalance(string $provider): void
    {
        $float = FloatAccount::where('provider', $provider)->first();
        if ($float && $float->balance < 50000) { // $500.00 fallback threshold
            Log::warning("LOW BALANCE ALERT: $provider float is currently at $" . ($float->balance / 100));
            // Trigger alerts (Slack, Email, SMS)
        }
    }
}
