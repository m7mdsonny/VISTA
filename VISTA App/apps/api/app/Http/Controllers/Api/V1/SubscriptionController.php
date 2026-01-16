<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\SubscriptionVerifyRequest;
use App\Models\Entitlement;
use App\Models\SubscriptionPlan;
use App\Services\SubscriptionService;
use App\Services\FeatureGateService;
use App\Services\PromotionService;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function __construct(
        private SubscriptionService $subscriptionService,
        private FeatureGateService $featureGateService,
        private PromotionService $promotionService
    ) {
    }

    public function status(Request $request)
    {
        $user = $request->user();
        $subscription = $this->subscriptionService->getActiveSubscription($user);
        $isInTrial = $this->subscriptionService->isInTrial($user);

        $plan = $subscription?->plan ?? SubscriptionPlan::where('code', 'free')->first();
        $planCode = $plan?->code ?? 'free';

        // Get entitlements from subscription or default free plan
        $entitlements = $this->buildEntitlementsResponse($user, $plan);

        return response()->json([
            'plan' => [
                'code' => $planCode,
                'name' => $plan?->name_ar ?? 'مجاني',
                'isActive' => $subscription?->status === 'active' ?? false,
            ],
            'entitlements' => $entitlements,
            'trial' => [
                'isActive' => $isInTrial,
                'daysRemaining' => $subscription?->trial_ends_at
                    ? max(0, now()->diffInDays($subscription->trial_ends_at, false))
                    : 0,
                'endsAt' => $subscription?->trial_ends_at?->toIso8601String(),
            ],
            'subscription' => $subscription ? [
                'status' => $subscription->status,
                'expiresAt' => $subscription->expires_at?->toIso8601String(),
                'platform' => $subscription->platform,
            ] : null,
        ]);
    }

    public function plans(Request $request)
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        // Get active promotions
        $promotions = $this->promotionService->getActivePromotionsForPlan();

        return response()->json([
            'data' => $plans->map(function ($plan) use ($promotions) {
                // Calculate prices with promotions
                $monthlyPrice = $plan->price_monthly ?? 0;
                $yearlyPrice = $plan->price_yearly ?? 0;

                // Find applicable promotions (simplified - apply best promotion)
                $bestPromotion = null;
                $bestDiscount = 0;

                foreach ($promotions as $promotion) {
                    if ($promotion['type'] === 'percentage') {
                        $discount = ($monthlyPrice * $promotion['discount_value']) / 100;
                        if ($discount > $bestDiscount) {
                            $bestDiscount = $discount;
                            $bestPromotion = $promotion;
                        }
                    }
                }

                return [
                    'code' => $plan->code,
                    'name' => $plan->name_ar,
                    'nameEn' => $plan->name_en,
                    'description' => $plan->description_ar ?? '',
                    'priceMonthly' => $monthlyPrice,
                    'priceYearly' => $yearlyPrice,
                    'discountedPriceMonthly' => $bestPromotion ? max(0, $monthlyPrice - $bestDiscount) : null,
                    'discountedPriceYearly' => $bestPromotion ? max(0, $yearlyPrice - ($yearlyPrice * $bestPromotion['discount_value'] / 100)) : null,
                    'promotion' => $bestPromotion,
                    'trialDays' => $plan->trial_days ?? 14,
                    'features' => $plan->features ?? [],
                    'isActive' => $plan->is_active,
                ];
            }),
            'promotions' => $promotions,
        ]);
    }

    public function validatePromotion(Request $request)
    {
        $request->validate([
            'code' => 'required|string|max:50',
            'plan_code' => 'required|string|exists:subscription_plans,code',
        ]);

        $user = $request->user();
        $result = $this->promotionService->validateAndApply(
            $request->input('code'),
            $user,
            $request->input('plan_code')
        );

        if (!$result['valid']) {
            return response()->json([
                'valid' => false,
                'message' => $result['message'],
            ], 400);
        }

        $promotion = $result['promotion'];
        $plan = SubscriptionPlan::where('code', $request->input('plan_code'))->first();

        // Calculate pricing with promotion
        $isYearly = $request->has('is_yearly') && $request->input('is_yearly');
        $pricing = $this->promotionService->applyPromotion($promotion, $plan, $isYearly);

        return response()->json([
            'valid' => true,
            'promotion' => [
                'code' => $promotion->code,
                'name' => $promotion->name_ar,
                'description' => $promotion->description_ar,
                'type' => $promotion->type,
                'discount_value' => $promotion->discount_value,
            ],
            'pricing' => $pricing,
        ]);
    }

    public function verifyApple(SubscriptionVerifyRequest $request)
    {
        $user = $request->user();
        $receipt = $request->input('receipt');
        $productId = $request->input('product_id');
        $transactionId = $request->input('transaction_id');

        $subscription = $this->subscriptionService->verifyAppleReceipt(
            $user,
            $receipt,
            $productId,
            $transactionId
        );

        if (!$subscription) {
            return response()->json([
                'message' => 'Invalid receipt or receipt already processed.',
                'status' => 'invalid',
            ], 400);
        }

        return response()->json([
            'status' => 'valid',
            'plan' => [
                'code' => $subscription->plan->code,
                'name' => $subscription->plan->name_ar,
                'isActive' => $subscription->plan->is_active,
            ],
            'entitlements' => $this->buildEntitlementsResponse($user, $subscription->plan),
            'subscription' => [
                'status' => $subscription->status,
                'expiresAt' => $subscription->expires_at?->toIso8601String(),
                'trialEndsAt' => $subscription->trial_ends_at?->toIso8601String(),
            ],
        ]);
    }

    public function verifyGoogle(SubscriptionVerifyRequest $request)
    {
        $user = $request->user();
        $purchaseToken = $request->input('purchase_token');
        $productId = $request->input('product_id');
        $transactionId = $request->input('transaction_id');

        $subscription = $this->subscriptionService->verifyGooglePurchase(
            $user,
            $purchaseToken,
            $productId,
            $transactionId
        );

        if (!$subscription) {
            return response()->json([
                'message' => 'Invalid purchase or purchase already processed.',
                'status' => 'invalid',
            ], 400);
        }

        return response()->json([
            'status' => 'valid',
            'plan' => [
                'code' => $subscription->plan->code,
                'name' => $subscription->plan->name_ar,
                'isActive' => $subscription->plan->is_active,
            ],
            'entitlements' => $this->buildEntitlementsResponse($user, $subscription->plan),
            'subscription' => [
                'status' => $subscription->status,
                'expiresAt' => $subscription->expires_at?->toIso8601String(),
                'trialEndsAt' => $subscription->trial_ends_at?->toIso8601String(),
            ],
        ]);
    }

    private function buildEntitlementsResponse($user, $plan): array
    {
        $features = $plan->features ?? [];

        return [
            'signals' => $this->featureGateService->canAccess($user, 'signals'),
            'alerts' => $this->featureGateService->canAccess($user, 'alerts'),
            'watchlists' => $this->featureGateService->getFeatureValue($user, 'watchlists') ?? ($features['watchlists'] ?? 1),
            'advancedAnalytics' => $this->featureGateService->canAccess($user, 'advancedAnalytics'),
            'education' => $this->featureGateService->canAccess($user, 'education'),
            'paperPortfolio' => $this->featureGateService->canAccess($user, 'paperPortfolio'),
            'backtesting' => $this->featureGateService->canAccess($user, 'backtesting'),
        ];
    }
}
