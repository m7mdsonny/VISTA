<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ApiProviderLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'provider_id',
        'endpoint',
        'status',
        'response_time_ms',
        'http_status_code',
        'error_message',
        'request_data',
        'response_data',
        'requested_at',
    ];

    protected $casts = [
        'request_data' => 'array',
        'response_data' => 'array',
        'requested_at' => 'datetime',
        'response_time_ms' => 'integer',
        'http_status_code' => 'integer',
    ];

    public function provider()
    {
        return $this->belongsTo(ApiProvider::class, 'provider_id');
    }
}
