<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FxRate;
use App\Models\FeeSetting;
use App\Services\WallesterService;
use App\Services\TransactionService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class WallesterBridgeController extends Controller
{
    protected WallesterService $wallester;
    protected TransactionService $transactions;

    public function __construct(WallesterService $wallester, TransactionService $transactions)
    {
        $this->wallester    = $wallester;
        $this->transactions = $transactions;
    }

    /**
     * 1. WALLESTER WEBHOOK — receives pay-in events from Europe
     */
    public function handleWebhook(Request $request): JsonResponse
    {
        // Signature Verification
        if (!$this->wallester->verifySignature($request)) {
            Log::warning('Invalid Wallester webhook signature');
            return response()->json(['error' => 'Invalid signature'], 403);
        }

        $payload = $request->json()->all();
        $event   = $payload['event_type'] ?? '';

        return match ($event) {
            'payment.completed' => $this->processPayIn($payload),
            'payment.failed'    => $this->handleFailedPayIn($payload),
            'refund.processed'  => $this->handleRefund($payload),
            default             => response()->json(['message' => 'Event ignored'], 200),
        };
    }

    /**
     * 2. PROCESS SUCCESSFUL PAY-IN → trigger The Bridge via TransactionService
     */
    private function processPayIn(array $payload): JsonResponse
    {
        try {
            $data = $this->wallester->parsePayload($payload);

            // Execute the Bridge (Ledger + Payout)
            $transaction = $this->transactions->processRemittanceBridge($data);

            return response()->json([
                'message'      => 'Pay-in processed successfully',
                'reference'    => $transaction->reference,
                'status'       => $transaction->status,
                'amount_eur'   => $transaction->amount / 100,
                'amount_usd'   => $transaction->net_amount / 100,
                'rate_used'    => $transaction->exchange_rate,
            ], 200);

        } catch (\Throwable $e) {
            Log::error('Bridge Processing failed: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * 3. CALCULATE FX CONVERSION (Client-facing Estimator)
     */
    public function calculateFxConversion(Request $request): JsonResponse
    {
        $amountEurCents = (int) ($request->input('amount', 0) * 100);
        $fxRate         = FxRate::activeRate('EUR', 'USD');
        $feeSetting      = FeeSetting::applicableFor($amountEurCents, 'EUR', 'USD');

        if (!$fxRate) {
            return response()->json(['error' => 'No FX rate configured'], 503);
        }

        $fee    = $feeSetting ? $feeSetting->calculateFee($amountEurCents) : 0;
        $netEur = $amountEurCents - $fee;
        $netUsd = $fxRate->convert($netEur);

        return response()->json([
            'from_amount'    => $amountEurCents / 100,
            'from_currency'  => 'EUR',
            'fee_amount'     => $fee / 100,
            'net_from'       => $netEur / 100,
            'to_amount'      => $netUsd / 100,
            'to_currency'    => 'USD',
            'rate'           => $fxRate->effective_rate,
        ]);
    }

    /**
     * 4. HANDLE FAILED PAY-IN
     */
    private function handleFailedPayIn(array $payload): JsonResponse
    {
        Log::warning('Wallester pay-in failed', $payload);
        return response()->json(['message' => 'Failure recorded'], 200);
    }

    /**
     * 5. HANDLE REFUND
     */
    private function handleRefund(array $payload): JsonResponse
    {
        Log::info('Refund processed', $payload);
        return response()->json(['message' => 'Refund recorded'], 200);
    }
}
