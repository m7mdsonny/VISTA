<?php

namespace Tests\Unit;

use App\Models\User;
use App\Models\SubscriptionPlan;
use App\Models\Subscription;
use App\Models\Entitlement;
use App\Services\FeatureGateService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FeatureGateServiceTest extends TestCase
{
    use RefreshDatabase;

    private FeatureGateService $featureGate;

    protected function setUp(): void
    {
        parent::setUp();

        $this->featureGate = $this->app->make(FeatureGateService::class);
    }

    public function test_free_user_cannot_access_signals(): void
    {
        $user = User::factory()->create();

        // No subscription = free plan
        $canAccess = $this->featureGate->canAccess($user, 'signals');

        $this->assertFalse($canAccess);
    }

    public function test_premium_user_can_access_signals(): void
    {
        $user = User::factory()->create();
        $plan = SubscriptionPlan::factory()->create([
            'code' => 'pro',
            'features' => ['signals' => true],
        ]);

        Subscription::factory()->create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'status' => 'active',
        ]);

        // Entitlements should be created automatically
        Entitlement::factory()->create([
            'user_id' => $user->id,
            'plan_code' => $plan->code,
            'feature_key' => 'signals',
            'feature_value' => 'true',
        ]);

        $canAccess = $this->featureGate->canAccess($user, 'signals');

        $this->assertTrue($canAccess);
    }

    public function test_watchlist_limit_respected(): void
    {
        $user = User::factory()->create();
        $plan = SubscriptionPlan::factory()->create([
            'code' => 'free',
            'features' => ['watchlists' => 1], // Limited to 1
        ]);

        Entitlement::factory()->create([
            'user_id' => $user->id,
            'plan_code' => $plan->code,
            'feature_key' => 'watchlists',
            'feature_value' => '1',
        ]);

        // Check if user can create first watchlist
        $canCreateFirst = $this->featureGate->canPerformAction($user, 'create_watchlist', 0);
        $this->assertTrue($canCreateFirst);

        // Check if user can create second watchlist (should fail)
        $canCreateSecond = $this->featureGate->canPerformAction($user, 'create_watchlist', 1);
        $this->assertFalse($canCreateSecond);
    }
}
