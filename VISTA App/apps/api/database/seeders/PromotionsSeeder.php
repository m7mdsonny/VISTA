<?php

namespace Database\Seeders;

use App\Models\Promotion;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class PromotionsSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        // 50% OFF for new users
        Promotion::create([
            'code' => 'NEWUSER50',
            'name_ar' => 'خصم 50% للمستخدمين الجدد',
            'name_en' => '50% OFF for New Users',
            'description_ar' => 'احصل على خصم 50% على جميع الخطط لمدة 3 أشهر',
            'type' => 'percentage',
            'discount_value' => 50,
            'max_discount_amount' => null,
            'applies_to' => 'all',
            'frequency' => 'once',
            'usage_limit' => 1000,
            'per_user_limit' => 1,
            'starts_at' => $now,
            'ends_at' => $now->copy()->addMonths(3),
            'is_active' => true,
            'priority' => 100,
        ]);

        // Summer Sale - 30% OFF
        Promotion::create([
            'code' => 'SUMMER30',
            'name_ar' => 'عرض الصيف - خصم 30%',
            'name_en' => 'Summer Sale - 30% OFF',
            'description_ar' => 'خصم 30% على جميع الخطط حتى نهاية الصيف',
            'type' => 'percentage',
            'discount_value' => 30,
            'applies_to' => 'all',
            'frequency' => 'once',
            'usage_limit' => null, // Unlimited
            'per_user_limit' => 1,
            'starts_at' => $now,
            'ends_at' => $now->copy()->addMonths(1),
            'is_active' => true,
            'priority' => 90,
        ]);

        // Free trial extension - 30 days
        Promotion::create([
            'code' => 'TRIAL30',
            'name_ar' => 'تجربة مجانية 30 يوم',
            'name_en' => '30 Days Free Trial',
            'description_ar' => 'احصل على 30 يوم تجربة مجانية بدلاً من 14 يوم',
            'type' => 'free_trial',
            'free_trial_days' => 30,
            'applies_to' => 'all',
            'frequency' => 'once',
            'usage_limit' => 500,
            'per_user_limit' => 1,
            'starts_at' => $now,
            'ends_at' => $now->copy()->addMonths(6),
            'is_active' => true,
            'priority' => 80,
        ]);

        // Pro Plan specific - 25% OFF
        Promotion::create([
            'code' => 'PRO25',
            'name_ar' => 'خصم 25% على خطة Pro',
            'name_en' => '25% OFF on Pro Plan',
            'description_ar' => 'خصم خاص 25% على خطة Pro فقط',
            'type' => 'percentage',
            'discount_value' => 25,
            'applies_to' => 'specific_plans',
            'applicable_plan_codes' => ['pro'],
            'frequency' => 'once',
            'usage_limit' => null,
            'per_user_limit' => 1,
            'starts_at' => $now,
            'ends_at' => $now->copy()->addMonths(2),
            'is_active' => true,
            'priority' => 85,
        ]);

        // Fixed discount - 100 EGP OFF
        Promotion::create([
            'code' => 'SAVE100',
            'name_ar' => 'وفر 100 جنيه',
            'name_en' => 'Save 100 EGP',
            'description_ar' => 'خصم ثابت 100 جنيه على أي خطة سنوية',
            'type' => 'fixed',
            'discount_value' => 100,
            'applies_to' => 'all',
            'frequency' => 'once',
            'usage_limit' => 200,
            'per_user_limit' => 1,
            'minimum_plan_duration_months' => 12, // Only yearly
            'starts_at' => $now,
            'ends_at' => $now->copy()->addMonths(1),
            'is_active' => true,
            'priority' => 75,
        ]);
    }
}
