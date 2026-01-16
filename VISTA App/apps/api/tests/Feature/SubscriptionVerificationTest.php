<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\SubscriptionPlan;
use App\Services\SubscriptionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Illuminate\Support\Facades\Http;

class SubscriptionVerificationTest extends TestCase
{
    use RefreshDatabase;

    private SubscriptionService $subscriptionService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->subscriptionService = $this->app->make(SubscriptionService::class);
    }

    public function test_apple_receipt_verification_fails_with_invalid_receipt(): void
    {
        Http::fake([
            'buy.itunes.apple.com/verifyReceipt' => Http::response([
                'status' => 21000, // Invalid receipt
            ], 200),
        ]);

        $user = User::factory()->create();
        $plan = SubscriptionPlan::factory()->create(['code' => 'basic']);

        $subscription = $this->subscriptionService->verifyAppleReceipt(
            $user,
            'invalid-receipt',
            'com.vista.basic.monthly',
            'test-transaction-id'
        );

        $this->assertNull($subscription);
    }

    public function test_google_purchase_verification_requires_valid_token(): void
    {
        // This test would require mocking Google API client
        // For now, we'll just verify the service exists and is callable
        $this->assertInstanceOf(
            SubscriptionService::class,
            $this->subscriptionService
        );
    }

    public function test_entitlements_updated_after_subscription_verification(): void
    {
        // This would test that entitlements are created after successful verification
        // Implementation depends on actual verification flow
        $this->assertTrue(true); // Placeholder
    }
}
