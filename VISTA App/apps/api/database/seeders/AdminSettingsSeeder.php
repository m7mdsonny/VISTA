<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AdminSetting;

class AdminSettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            'trial_days' => ['days' => 14],
            'feature_flags' => [
                'signals' => true,
                'alerts' => true,
                'advancedAnalytics' => true,
                'education' => true,
                'paperPortfolio' => true,
            ],
            'analysis_weights' => [
                'rsi' => 0.3,
                'ma' => 0.3,
                'volume' => 0.2,
                'volatility' => 0.2,
            ],
            'analysis_thresholds' => [
                'rsi_oversold' => 30,
                'rsi_overbought' => 70,
                'volume_spike' => 1.5,
            ],
            'notification_rules' => [
                'quiet_hours_start' => '22:00',
                'quiet_hours_end' => '07:00',
                'repeat_window_hours' => 6,
            ],
            'legal_texts' => [
                'disclaimer' => 'هذه المنصة تقدم إشارات تحليلية استرشادية فقط ولا تضمن أي أرباح.',
            ],
            'banners' => [
                'message' => 'مرحباً بك في Vista',
            ],
            'maintenance' => [
                'enabled' => false,
                'message' => 'جاري تنفيذ تحديثات مجدولة.',
            ],
        ];

        foreach ($settings as $key => $value) {
            AdminSetting::updateOrCreate(['key' => $key], ['value_json' => $value]);
        }
    }
}
