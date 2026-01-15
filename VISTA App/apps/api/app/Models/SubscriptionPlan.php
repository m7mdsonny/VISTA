<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name_ar',
        'price_display_ar',
        'features_json',
        'is_active',
        'sort',
    ];

    protected $casts = [
        'features_json' => 'array',
        'is_active' => 'boolean',
    ];
}
