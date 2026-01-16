<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserPromotion extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'promotion_id',
        'subscription_id',
        'discount_applied',
        'original_price',
        'final_price',
        'used_at',
    ];

    protected $casts = [
        'discount_applied' => 'decimal:2',
        'original_price' => 'decimal:2',
        'final_price' => 'decimal:2',
        'used_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function promotion()
    {
        return $this->belongsTo(Promotion::class);
    }

    public function subscription()
    {
        return $this->belongsTo(Subscription::class);
    }
}
