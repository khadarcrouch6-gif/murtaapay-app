<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    protected $fillable = [
        'user_id',
        'action',
        'description',
        'subject_type',
        'subject_id',
        'ip_address',
        'user_agent',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /** Log a model change */
    public static function record(
        string $action,
        ?Model $model = null,
        array $oldValues = [],
        array $newValues = []
    ): void {
        static::create([
            'user_id'      => auth()->id(),
            'action'       => $action,
            'subject_type' => $model ? get_class($model) : null,
            'subject_id'   => $model?->getKey(),
            'metadata'     => [
                'old' => $oldValues,
                'new' => $newValues,
            ],
            'ip_address'   => request()->ip(),
            'user_agent'   => request()->userAgent(),
        ]);
    }
}
