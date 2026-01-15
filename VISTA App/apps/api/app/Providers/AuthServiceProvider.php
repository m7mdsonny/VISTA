<?php

namespace App\Providers;

use App\Models\Signal;
use App\Policies\SignalPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Signal::class => SignalPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}
