<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Alert extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'type',
        'payload_json',
        'is_read',
    ];

    protected $casts = [
        'payload_json' => 'array',
        'is_read' => 'boolean',
    ];
}
