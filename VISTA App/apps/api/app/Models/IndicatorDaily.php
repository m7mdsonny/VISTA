<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IndicatorDaily extends Model
{
    use HasFactory;

    protected $fillable = [
        'stock_id',
        'date',
        'rsi',
        'ma20',
        'ma50',
        'ma200',
        'vol20',
        'vol60',
        'avg_volume20',
        'avg_volume60',
    ];

    protected $casts = [
        'date' => 'date',
    ];
}
