<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\Wallet;

class WalletController extends Controller
{
    public function index(Request $request)
    {
        $wallets = $request->user()->wallets()->get();

        return response()->json($wallets);
    }
}
