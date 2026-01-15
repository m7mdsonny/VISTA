<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\SubscriptionVerifyRequest;
use App\Models\Entitlement;
use App\Models\SubscriptionPlan;
use App\Models\AdminSetting;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function status(Request $request)
    {
        $user = $request->user();
        $entitlement = Entitlement::where('user_id', $user->id)->latest()->first();
        $plan = $entitlement
            ? SubscriptionPlan::where('code', $entitlement->plan_code)->first()
            : SubscriptionPlan::where('code', 'free')->first();

        $trialDays = AdminSetting::where('key', 'trial_days')->value('value_json') ?? ['days' => 14];

        return response()->json([
            'plan' => [
                'code' => $plan?->code ?? 'free',
                'name' => $plan?->name_ar ?? 'مجاني',
                'isActive' => $plan?->is_active ?? true,
            ],
            'entitlements' => $plan?->features_json ?? [
                'signals' => true,
                'alerts' => true,
                'advancedAnalytics' => false,
                'education' => false,
                'paperPortfolio' => false,
            ],
            'trial' => [
                'isActive' => $entitlement?->trial_ends_at?->isFuture() ?? true,
                'daysRemaining' => $entitlement?->trial_ends_at?->diffInDays() ?? ($trialDays['days'] ?? 14),
            ],
        ]);
    }

    public function verifyApple(SubscriptionVerifyRequest $request)
    {
        return $this->verifySubscription($request->user()->id, 'apple', $request->validated());
    }

    public function verifyGoogle(SubscriptionVerifyRequest $request)
    {
        return $this->verifySubscription($request->user()->id, 'google', $request->validated());
    }

    private function verifySubscription(int $userId, string $platform, array $payload)
    {
        $plan = SubscriptionPlan::where('code', 'pro')->first();

        $entitlement = Entitlement::updateOrCreate([
            'user_id' => $userId,
            'plan_code' => $plan?->code ?? 'pro',
        ], [
            'status' => 'active',
            'current_period_ends_at' => now()->addMonth(),
            'trial_ends_at' => now()->addDays(14),
            'meta_json' => [
                'platform' => $platform,
                'payload' => $payload,
            ],
        ]);

        return response()->json([
            'status' => 'valid',
            'plan' => [
                'code' => $plan?->code ?? 'pro',
                'name' => $plan?->name_ar ?? 'احترافي',
                'isActive' => $plan?->is_active ?? true,
            ],
            'entitlements' => $plan?->features_json ?? [],
        ]);
    }
}
