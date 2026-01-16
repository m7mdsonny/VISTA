<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SubscriptionPlan;

class PlansSeeder extends Seeder
{
    public function run(): void
    {
        $plans = [
            [
                'code' => 'free',
                'name_ar' => 'مجاني',
                'name_en' => 'Free',
                'description_ar' => 'خطة مجانية محدودة',
                'price_monthly' => 0,
                'price_yearly' => null,
                'trial_days' => 0,
                'features' => [
                    'signals' => false,
                    'alerts' => false,
                    'watchlists' => 1, // Limited to 1 watchlist
                    'advancedAnalytics' => false,
                    'education' => false,
                    'paperPortfolio' => false,
                    'backtesting' => false,
                ],
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'code' => 'basic',
                'name_ar' => 'أساسي',
                'name_en' => 'Basic',
                'description_ar' => 'إشارات كاملة وقوائم متابعة غير محدودة',
                'price_monthly' => 299.00,
                'price_yearly' => 2990.00,
                'trial_days' => 14,
                'features' => [
                    'signals' => true,
                    'alerts' => true,
                    'watchlists' => -1, // Unlimited
                    'advancedAnalytics' => false,
                    'education' => true,
                    'paperPortfolio' => false,
                    'backtesting' => false,
                ],
                'is_active' => true,
                'sort_order' => 2,
            ],
            [
                'code' => 'pro',
                'name_ar' => 'احترافي',
                'name_en' => 'Pro',
                'description_ar' => 'جميع المزايا المتقدمة',
                'price_monthly' => 599.00,
                'price_yearly' => 5990.00,
                'trial_days' => 14,
                'features' => [
                    'signals' => true,
                    'alerts' => true,
                    'watchlists' => -1, // Unlimited
                    'advancedAnalytics' => true,
                    'education' => true,
                    'paperPortfolio' => true,
                    'backtesting' => true,
                ],
                'is_active' => true,
                'sort_order' => 3,
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['code' => $plan['code']],
                $plan
            );
        }
    }
}
