<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'platform',
        'amount',
        'currency',
        'raw_json',
    ];

    protected $casts = [
        'raw_json' => 'array',
    ];
}
