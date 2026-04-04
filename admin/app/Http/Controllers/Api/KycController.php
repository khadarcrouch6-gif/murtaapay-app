<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\KycVerification;
use Illuminate\Support\Facades\Storage;

class KycController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'id_type' => 'required|string',
            'id_number' => 'required|string',
            'id_front' => 'required|image|max:5120', // Max 5MB
            'id_back' => 'nullable|image|max:5120',
            'selfie' => 'required|image|max:5120',
        ]);

        $user = $request->user();

        // 1. Check if user already has a pending or verified KYC
        if ($user->kycVerification && in_array($user->kycVerification->status, ['pending', 'verified'])) {
            return response()->json([
                'message' => 'You already have a ' . $user->kycVerification->status . ' verification request.'
            ], 422);
        }

        // 2. Store Images
        $idFrontPath = $request->file('id_front')->store('kyc/ids', 'public');
        $idBackPath = $request->hasFile('id_back') ? $request->file('id_back')->store('kyc/ids', 'public') : null;
        $selfiePath = $request->file('selfie')->store('kyc/selfies', 'public');

        // 3. Create or Update record
        $kyc = KycVerification::updateOrCreate(
            ['user_id' => $user->id],
            [
                'id_type' => $request->id_type,
                'id_number' => $request->id_number,
                'id_front_path' => $idFrontPath,
                'id_back_path' => $idBackPath,
                'selfie_path' => $selfiePath,
                'status' => 'pending',
                'admin_notes' => null,
            ]
        );

        return response()->json([
            'message' => 'KYC documents uploaded successfully. We will review them shortly.',
            'kyc' => $kyc
        ]);
    }

    public function status(Request $request)
    {
        $kyc = $request->user()->kycVerification;
        
        if (!$kyc) {
            return response()->json(['status' => 'not_submitted']);
        }

        return response()->json([
            'status' => $kyc->status,
            'admin_notes' => $kyc->admin_notes,
            'submitted_at' => $kyc->created_at,
        ]);
    }
}
