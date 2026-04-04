<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;

class WallesterService
{
    protected string $webhookSecret;

    public function __construct()
    {
        $this->webhookSecret = config('services.wallester.webhook_secret', 'mtp_wallester_default_secret');
    }

    /**
     * Verify the Wallester webhook signature.
     */
    public function verifySignature(Request $request): bool
    {
        $signature = $request->header('X-Wallester-Signature');
        
        if (!$signature) {
            return false;
        }

        $expected = hash_hmac('sha256', $request->getContent(), $this->webhookSecret);
        
        return hash_equals($expected, (string) $signature);
    }

    /**
     * Parse and normalize the Wallester payload.
     */
    public function parsePayload(array $payload): array
    {
        return [
            'event_type'      => $payload['event_type'] ?? 'unknown',
            'charge_id'       => $payload['charge_id'] ?? null,
            'amount_cents'    => (int) (($payload['amount'] ?? 0) * 100),
            'currency'        => strtoupper($payload['currency'] ?? 'EUR'),
            'user_id'         => $payload['metadata']['user_id'] ?? null,
            'recipient_phone' => $payload['metadata']['recipient_phone'] ?? null,
            'card_last4'      => $payload['card']['last4'] ?? null,
            'raw'             => $payload,
        ];
    }

    /**
     * Mock method to issue a virtual card (future implementation).
     */
    public function issueVirtualCard(int $userId, string $type = 'virtual'): array
    {
        // TODO: Real API Call to Wallester
        Log::info("Issuing $type card for user $userId via Wallester");
        
        return [
            'success'  => true,
            'card_id'  => 'WAL-' . strtoupper(\Illuminate\Support\Str::random(10)),
            'status'   => 'active',
        ];
    }
}
