<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\User;
use App\Models\Wallet;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $transactions = $request->user()->transactions()
            ->with(['wallet'])
            ->latest()
            ->paginate(20);

        // Transform the collection to match the fintech design
        $transformed = $transactions->getCollection()->map(function ($txn) {
            return [
                'id'             => 'txn_' . str_pad($txn->id, 7, '0', STR_PAD_LEFT),
                'reference'      => $txn->reference,
                'type'           => $txn->type,
                'status'         => $txn->status,
                'status_label'   => ucfirst($txn->status === 'completed' ? 'Delivered' : $txn->status),
                'amount'         => (float) ($txn->amount / 100),
                'net_amount'     => (float) ($txn->net_amount / 100),
                'fee'            => (float) ($txn->fee_amount / 100),
                'currency'       => $txn->currency,
                'target_currency'=> 'USD', // Based on current EUR->USD flow
                'exchange_rate'  => (float) $txn->exchange_rate,
                'recipient'      => $txn->recipient_identifier,
                'description'    => $txn->description,
                'timestamp'      => $txn->created_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $transformed,
            'meta'    => [
                'current_page' => $transactions->currentPage(),
                'last_page'    => $transactions->lastPage(),
                'per_page'     => $transactions->perPage(),
                'total'        => $transactions->total(),
            ]
        ]);
    }

    public function transfer(Request $request)
    {
        $request->validate([
            'amount' => 'required|integer|min:1',
            'recipient_identifier' => 'required|string', // Dynamic: email or phone
            'currency' => 'required|string|max:3',
            'description' => 'nullable|string|max:255',
        ]);

        $sender = $request->user();
        $amount = $request->amount;
        $currency = strtoupper($request->currency);

        // 1. Find Sender Wallet
        $senderWallet = $sender->wallets()->where('currency', $currency)->first();
        if (!$senderWallet || $senderWallet->balance < $amount) {
            return response()->json(['message' => 'Insufficient funds or wallet not found'], 422);
        }

        // 2. Find Recipient
        $recipient = User::where('email', $request->recipient_identifier)
            ->orWhere('phone_number', $request->recipient_identifier)
            ->first();

        if (!$recipient || $recipient->id === $sender->id) {
            return response()->json(['message' => 'Invalid recipient'], 422);
        }

        // 3. Find Recipient Wallet (Auto-create if not exists)
        $recipientWallet = $recipient->wallets()->firstOrCreate(
            ['currency' => $currency],
            ['balance' => 0, 'status' => 'active']
        );

        return DB::transaction(function () use ($sender, $recipient, $senderWallet, $recipientWallet, $amount, $currency, $request) {
            // Deduct from sender
            $senderWallet->decrement('balance', $amount);

            // Add to recipient
            $recipientWallet->increment('balance', $amount);

            // Create Transaction record for Sender (Debit)
            $sender->transactions()->create([
                'wallet_id' => $senderWallet->id,
                'type' => 'send',
                'amount' => $amount,
                'fee' => 0, // Could add business logic here
                'currency' => $currency,
                'status' => 'completed',
                'reference' => 'TXN-' . strtoupper(Str::random(12)),
                'recipient_identifier' => $recipient->email,
                'description' => 'Transfer to ' . $recipient->name . ': ' . $request->description,
            ]);

            // Create Transaction record for Recipient (Credit)
            $recipient->transactions()->create([
                'wallet_id' => $recipientWallet->id,
                'type' => 'transfer',
                'amount' => $amount,
                'fee' => 0,
                'currency' => $currency,
                'status' => 'completed',
                'reference' => 'TXN-' . strtoupper(Str::random(12)),
                'recipient_identifier' => $sender->email,
                'description' => 'Received from ' . $sender->name,
            ]);

            return response()->json([
                'message' => 'Transfer successful',
                'sender_balance' => $senderWallet->fresh()->balance,
            ]);
        });
    }
}
