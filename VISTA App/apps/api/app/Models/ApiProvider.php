<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class ApiProvider extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'display_name_ar',
        'display_name_en',
        'type',
        'base_url',
        'api_key',
        'api_secret',
        'headers',
        'endpoints',
        'auth_type',
        'rate_limit_per_minute',
        'rate_limit_per_day',
        'is_active',
        'is_default',
        'timeout_seconds',
        'retry_attempts',
        'notes',
    ];

    protected $casts = [
        'headers' => 'array',
        'endpoints' => 'array',
        'is_active' => 'boolean',
        'is_default' => 'boolean',
        'rate_limit_per_minute' => 'integer',
        'rate_limit_per_day' => 'integer',
        'timeout_seconds' => 'integer',
        'retry_attempts' => 'integer',
    ];

    protected $hidden = [
        'api_key',
        'api_secret',
    ];

    /**
     * Get encrypted API key
     */
    public function getApiKeyAttribute($value)
    {
        return $value ? Crypt::decryptString($value) : null;
    }

    /**
     * Set encrypted API key
     */
    public function setApiKeyAttribute($value)
    {
        $this->attributes['api_key'] = $value ? Crypt::encryptString($value) : null;
    }

    /**
     * Get encrypted API secret
     */
    public function getApiSecretAttribute($value)
    {
        return $value ? Crypt::decryptString($value) : null;
    }

    /**
     * Set encrypted API secret
     */
    public function setApiSecretAttribute($value)
    {
        $this->attributes['api_secret'] = $value ? Crypt::encryptString($value) : null;
    }

    public function logs()
    {
        return $this->hasMany(ApiProviderLog::class, 'provider_id');
    }
}
