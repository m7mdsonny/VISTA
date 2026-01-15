<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'actor_user_id',
        'action',
        'entity',
        'entity_id',
        'diff_json',
        'ip',
        'ua',
    ];

    protected $casts = [
        'diff_json' => 'array',
    ];
}
