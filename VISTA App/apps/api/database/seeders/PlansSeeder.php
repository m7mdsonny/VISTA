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
                'price_display_ar' => '0 ج.م',
                'features_json' => [
                    'signals' => true,
                    'alerts' => true,
                    'advancedAnalytics' => false,
                    'education' => false,
                    'paperPortfolio' => false,
                ],
                'sort' => 1,
            ],
            [
                'code' => 'basic',
                'name_ar' => 'أساسي',
                'price_display_ar' => '49 ج.م',
                'features_json' => [
                    'signals' => true,
                    'alerts' => true,
                    'advancedAnalytics' => true,
                    'education' => true,
                    'paperPortfolio' => false,
                ],
                'sort' => 2,
            ],
            [
                'code' => 'pro',
                'name_ar' => 'احترافي',
                'price_display_ar' => '99 ج.م',
                'features_json' => [
                    'signals' => true,
                    'alerts' => true,
                    'advancedAnalytics' => true,
                    'education' => true,
                    'paperPortfolio' => true,
                ],
                'sort' => 3,
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
