<?php

namespace App\Services;

use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\Entitlement;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class SubscriptionService
{
    /**
     * Verify and activate subscription from Apple receipt
     */
    public function verifyAppleReceipt(User $user, string $receipt, string $productId, string $transactionId): ?Subscription
    {
        try {
            // Verify with Apple App Store Server API
            $response = \Http::post('https://buy.itunes.apple.com/verifyReceipt', [
                'receipt-data' => $receipt,
                'password' => config('services.apple.shared_secret'),
                'exclude-old-transactions' => true,
            ]);

            $result = $response->json();

            // If sandbox receipt, verify against sandbox
            if (isset($result['status']) && $result['status'] === 21007) {
                $response = \Http::post('https://sandbox.itunes.apple.com/verifyReceipt', [
                    'receipt-data' => $receipt,
                    'password' => config('services.apple.shared_secret'),
                    'exclude-old-transactions' => true,
                ]);
                $result = $response->json();
            }

            // Validate receipt
            if (!isset($result['status']) || $result['status'] !== 0) {
                Log::warning('Invalid Apple receipt', ['status' => $result['status'] ?? 'unknown']);
                return null;
            }

            // Extract subscription info
            $latestReceiptInfo = $result['latest_receipt_info'][0] ?? null;
            if (!$latestReceiptInfo) {
                return null;
            }

            // Find or create plan based on product_id
            $plan = $this->findPlanByProductId($productId);
            if (!$plan) {
                Log::warning('Plan not found for product_id', ['product_id' => $productId]);
                return null;
            }

            // Calculate dates
            $expiresAt = isset($latestReceiptInfo['expires_date_ms'])
                ? Carbon::createFromTimestampMs($latestReceiptInfo['expires_date_ms'])
                : null;

            $trialEndsAt = $this->calculateTrialEnd($plan, $expiresAt);

            // Create or update subscription
            $subscription = Subscription::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'platform_transaction_id' => $transactionId,
                ],
                [
                    'plan_id' => $plan->id,
                    'platform' => 'ios',
                    'status' => $expiresAt && $expiresAt->isFuture() ? 'active' : 'expired',
                    'started_at' => now(),
                    'expires_at' => $expiresAt,
                    'trial_ends_at' => $trialEndsAt,
                    'receipt_data' => encrypt($receipt),
                    'last_verified_at' => now(),
                    'verification_failures' => 0,
                ]
            );

            // AUTOMATIC ACTIVATION: Update entitlements immediately
            $this->updateEntitlements($user, $plan);

            // Create invoice for tracking
            $this->createInvoice($subscription, 'paid');

            Log::info('Subscription activated automatically (Apple)', [
                'subscription_id' => $subscription->id,
                'user_id' => $user->id,
                'plan_code' => $plan->code,
                'status' => $subscription->status,
            ]);

            return $subscription;

        } catch (\Exception $e) {
            Log::error('Apple receipt verification error', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Verify and activate subscription from Google Play purchase
     */
    public function verifyGooglePurchase(User $user, string $purchaseToken, string $productId, string $transactionId): ?Subscription
    {
        try {
            // Initialize Google Play Developer API client
            $client = new \Google_Client();
            $client->setAuthConfig(json_decode(config('services.google.service_account_json'), true));
            $client->addScope('https://www.googleapis.com/auth/androidpublisher');

            $service = new \Google_Service_AndroidPublisher($client);

            // Verify purchase
            $purchase = $service->purchases_subscriptions->get(
                config('services.google.package_name'),
                $productId,
                $purchaseToken
            );

            // Validate purchase
            if (!$purchase || $purchase->getPaymentState() !== 1) {
                Log::warning('Invalid Google purchase', ['payment_state' => $purchase->getPaymentState() ?? 'unknown']);
                return null;
            }

            // Find plan
            $plan = $this->findPlanByProductId($productId);
            if (!$plan) {
                return null;
            }

            // Calculate dates
            $expiresAt = $purchase->getExpiryTimeMillis()
                ? Carbon::createFromTimestampMs($purchase->getExpiryTimeMillis())
                : null;

            $trialEndsAt = $this->calculateTrialEnd($plan, $expiresAt);

            // Create or update subscription
            $subscription = Subscription::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'platform_transaction_id' => $transactionId,
                ],
                [
                    'plan_id' => $plan->id,
                    'platform' => 'android',
                    'status' => $expiresAt && $expiresAt->isFuture() ? 'active' : 'expired',
                    'started_at' => now(),
                    'expires_at' => $expiresAt,
                    'trial_ends_at' => $trialEndsAt,
                    'receipt_data' => encrypt($purchaseToken),
                    'last_verified_at' => now(),
                    'verification_failures' => 0,
                ]
            );

            // AUTOMATIC ACTIVATION: Update entitlements immediately
            $this->updateEntitlements($user, $plan);

            // Create invoice for tracking
            $this->createInvoice($subscription, 'paid');

            Log::info('Subscription activated automatically (Google)', [
                'subscription_id' => $subscription->id,
                'user_id' => $user->id,
                'plan_code' => $plan->code,
                'status' => $subscription->status,
            ]);

            return $subscription;

        } catch (\Exception $e) {
            Log::error('Google purchase verification error', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Update user entitlements based on active subscription
     */
    public function updateEntitlements(User $user, SubscriptionPlan $plan): void
    {
        $features = $plan->features ?? [];

        // Delete old entitlements for this plan
        Entitlement::where('user_id', $user->id)
            ->where('plan_code', $plan->code)
            ->delete();

        // Create new entitlements
        foreach ($features as $featureKey => $featureValue) {
            if ($featureValue === false) {
                continue; // Skip disabled features
            }

            Entitlement::create([
                'user_id' => $user->id,
                'plan_code' => $plan->code,
                'feature_key' => $featureKey,
                'feature_value' => is_bool($featureValue) ? ($featureValue ? 'true' : 'false') : (string) $featureValue,
                'expires_at' => null, // Permanent until subscription expires
            ]);
        }
    }

    /**
     * Get user's active subscription
     */
    public function getActiveSubscription(User $user): ?Subscription
    {
        return Subscription::where('user_id', $user->id)
            ->where('status', 'active')
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->latest('started_at')
            ->first();
    }

    /**
     * Check if user is in trial period
     */
    public function isInTrial(User $user): bool
    {
        $subscription = $this->getActiveSubscription($user);

        if (!$subscription) {
            return false;
        }

        if (!$subscription->trial_ends_at) {
            return false;
        }

        return $subscription->trial_ends_at->isFuture() && $subscription->status === 'trial';
    }

    /**
     * Calculate trial end date
     */
    private function calculateTrialEnd(SubscriptionPlan $plan, ?Carbon $expiresAt): ?Carbon
    {
        $trialDays = $plan->trial_days ?? 14;

        if ($trialDays <= 0) {
            return null;
        }

        return now()->addDays($trialDays);
    }

    /**
     * Find plan by product ID (from Apple/Google)
     */
    private function findPlanByProductId(string $productId): ?SubscriptionPlan
    {
        // Map product IDs to plan codes (should be in config or database)
        $mapping = [
            'com.vista.basic.monthly' => 'basic',
            'com.vista.pro.monthly' => 'pro',
            // Add more mappings as needed
        ];

        $planCode = $mapping[$productId] ?? null;
        if (!$planCode) {
            return null;
        }

        return SubscriptionPlan::where('code', $planCode)->first();
    }

    /**
     * Create invoice for subscription
     */
    private function createInvoice(Subscription $subscription, string $status = 'paid'): void
    {
        $plan = $subscription->plan;
        $invoiceNumber = 'INV-' . now()->format('Ymd') . '-' . str_pad($subscription->id, 6, '0', STR_PAD_LEFT);

        \App\Models\Invoice::updateOrCreate(
            [
                'subscription_id' => $subscription->id,
                'invoice_number' => $invoiceNumber,
            ],
            [
                'user_id' => $subscription->user_id,
                'invoice_number' => $invoiceNumber,
                'plan_code' => $plan->code,
                'amount' => $subscription->final_price ?? $plan->price_monthly ?? 0,
                'currency' => 'EGP',
                'platform' => $subscription->platform,
                'platform_transaction_id' => $subscription->platform_transaction_id,
                'status' => $status,
                'paid_at' => $status === 'paid' ? now() : null,
            ]
        );
    }
}
