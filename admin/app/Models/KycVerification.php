<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KycVerification extends Model
{
    protected $fillable = [
        'user_id',
        'id_type',
        'id_number',
        'id_front_path',
        'id_back_path',
        'selfie_path',
        'admin_notes',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
