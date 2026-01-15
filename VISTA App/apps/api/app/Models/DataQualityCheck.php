<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DataQualityCheck extends Model
{
    use HasFactory;

    protected $fillable = [
        'date',
        'source',
        'score',
        'anomalies_json',
    ];

    protected $casts = [
        'date' => 'date',
        'anomalies_json' => 'array',
    ];
}
