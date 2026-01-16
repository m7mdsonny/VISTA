<?php

namespace App\Services;

use App\Models\Promotion;
use App\Models\User;
use App\Models\SubscriptionPlan;
use App\Models\UserPromotion;
use App\Models\Subscription;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class PromotionService
{
    /**
     * Validate and apply promotion code
     */
    public function validateAndApply(string $promotionCode, User $user, string $planCode): array
    {
        $promotion = Promotion::where('code', $promotionCode)->first();

        if (!$promotion) {
            return [
                'valid' => false,
                'message' => 'رمز العرض غير صحيح',
                'promotion' => null,
            ];
        }

        // Check if can be used
        $canUse = $promotion->canBeUsedBy($user, $planCode);

        if (!$canUse['can_use']) {
            return [
                'valid' => false,
                'message' => $canUse['reason'],
                'promotion' => null,
            ];
        }

        return [
            'valid' => true,
            'message' => 'العرض صحيح',
            'promotion' => $promotion,
        ];
    }

    /**
     * Apply promotion to subscription price
     */
    public function applyPromotion(Promotion $promotion, SubscriptionPlan $plan, bool $isYearly = false): array
    {
        $originalPrice = $isYearly ? ($plan->price_yearly ?? 0) : ($plan->price_monthly ?? 0);

        if ($promotion->type === 'free_trial') {
            // Free trial doesn't reduce price, but extends trial period
            $trialDays = $promotion->free_trial_days ?? $plan->trial_days ?? 14;

            return [
                'original_price' => $originalPrice,
                'discount_amount' => 0,
                'final_price' => $originalPrice,
                'trial_days' => $trialDays,
                'promotion_applied' => true,
            ];
        }

        // Calculate discount
        $discountAmount = $promotion->calculateDiscount($originalPrice);
        $finalPrice = max(0, $originalPrice - $discountAmount);

        return [
            'original_price' => $originalPrice,
            'discount_amount' => $discountAmount,
            'final_price' => $finalPrice,
            'trial_days' => $plan->trial_days ?? 14,
            'promotion_applied' => true,
        ];
    }

    /**
     * Record promotion usage
     */
    public function recordUsage(Promotion $promotion, User $user, Subscription $subscription, array $pricing): void
    {
        // Increment usage count
        $promotion->increment('usage_count');

        // Record user promotion
        UserPromotion::create([
            'user_id' => $user->id,
            'promotion_id' => $promotion->id,
            'subscription_id' => $subscription->id,
            'discount_applied' => $pricing['discount_amount'] ?? 0,
            'original_price' => $pricing['original_price'],
            'final_price' => $pricing['final_price'],
            'used_at' => now(),
        ]);

        Log::info('Promotion used', [
            'promotion_code' => $promotion->code,
            'user_id' => $user->id,
            'subscription_id' => $subscription->id,
            'discount' => $pricing['discount_amount'] ?? 0,
        ]);
    }

    /**
     * Get active promotions for a plan
     */
    public function getActivePromotionsForPlan(?string $planCode = null): array
    {
        $query = Promotion::where('is_active', true)
            ->where('starts_at', '<=', now())
            ->where('ends_at', '>=', now())
            ->orderByDesc('priority');

        if ($planCode) {
            $query->where(function ($q) use ($planCode) {
                $q->where('applies_to', 'all')
                    ->orWhere(function ($q2) use ($planCode) {
                        $q2->where('applies_to', 'specific_plans')
                            ->whereJsonContains('applicable_plan_codes', $planCode);
                    });
            });
        }

        return $query->get()->map(function ($promotion) {
            return [
                'code' => $promotion->code,
                'name' => $promotion->name_ar,
                'description' => $promotion->description_ar,
                'type' => $promotion->type,
                'discount_value' => $promotion->discount_value,
                'free_trial_days' => $promotion->free_trial_days,
                'ends_at' => $promotion->ends_at->toIso8601String(),
            ];
        })->toArray();
    }
}
