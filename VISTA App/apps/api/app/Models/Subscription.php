<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plan_id',
        'promotion_id',
        'platform',
        'platform_transaction_id',
        'receipt_data',
        'status',
        'started_at',
        'expires_at',
        'trial_ends_at',
        'cancelled_at',
        'last_verified_at',
        'verification_failures',
        'original_price',
        'discount_amount',
        'final_price',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'expires_at' => 'datetime',
        'trial_ends_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'last_verified_at' => 'datetime',
        'receipt_data' => 'encrypted',
        'verification_failures' => 'integer',
        'original_price' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'final_price' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    public function promotion()
    {
        return $this->belongsTo(Promotion::class);
    }
}
