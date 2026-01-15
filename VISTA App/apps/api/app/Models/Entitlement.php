<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Entitlement extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plan_code',
        'status',
        'current_period_ends_at',
        'trial_ends_at',
        'meta_json',
    ];

    protected $casts = [
        'current_period_ends_at' => 'datetime',
        'trial_ends_at' => 'datetime',
        'meta_json' => 'array',
    ];
}
