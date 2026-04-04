<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\KycController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\WallesterBridgeController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ── Public Routes ─────────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/settings', [SettingsController::class, 'index']);
Route::get('/cms/content', [SettingsController::class, 'cms']);

// ── Wallester Webhook (public — verified via HMAC signature in controller) ─
Route::post('/webhooks/wallester', [WallesterBridgeController::class, 'handleWebhook'])
    ->withoutMiddleware([\Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class]);

// ── FX Rate Calculator (public for web/mobile app UI) ────────────────────
Route::get('/fx/calculate', [WallesterBridgeController::class, 'calculateFxConversion']);

// ── Protected Routes (Sanctum) ─────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    // User & Profile
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // KYC
    Route::post('/kyc/upload', [KycController::class, 'upload']);
    Route::get('/kyc/status', [KycController::class, 'status']);

    // Wallet & Transactions
    Route::get('/wallets', [WalletController::class, 'index']);
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/transactions/transfer', [TransactionController::class, 'transfer']);
    Route::post('/transactions/withdraw', [TransactionController::class, 'withdraw']);

    // Virtual Cards
    Route::get('/virtual-cards', [AuthController::class, 'virtualCards']);
});
