<?php

namespace App\Services;

use App\Models\AdminSetting;
use App\Models\AuditLog;
use Illuminate\Support\Facades\Log;

class AdminConfigService
{
    /**
     * Get setting value by key
     */
    public function get(string $key, mixed $default = null): mixed
    {
        $setting = AdminSetting::where('key', $key)->first();

        if (!$setting) {
            return $default;
        }

        return $setting->value;
    }

    /**
     * Set setting value (with audit logging)
     */
    public function set(string $key, mixed $value, ?int $updatedBy = null): AdminSetting
    {
        $oldSetting = AdminSetting::where('key', $key)->first();
        $oldValue = $oldSetting?->value;

        $setting = AdminSetting::updateOrCreate(
            ['key' => $key],
            [
                'value' => $value,
                'category' => $this->extractCategory($key),
                'updated_by' => $updatedBy ?? auth()->id(),
            ]
        );

        // Log audit trail
        AuditLog::create([
            'user_id' => $updatedBy ?? auth()->id(),
            'action' => $oldSetting ? 'setting.updated' : 'setting.created',
            'resource_type' => 'AdminSetting',
            'resource_id' => $setting->id,
            'old_values' => $oldSetting ? ['value' => $oldValue] : null,
            'new_values' => ['value' => $value],
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);

        return $setting;
    }

    /**
     * Get indicator weights
     */
    public function getIndicatorWeights(): array
    {
        return [
            'volume' => (float) $this->get('indicator.volume.weight', 0.25),
            'liquidity' => (float) $this->get('indicator.liquidity.weight', 0.20),
            'trend' => (float) $this->get('indicator.trend.weight', 0.25),
            'mean_reversion' => (float) $this->get('indicator.mean_reversion.weight', 0.15),
            'volatility' => (float) $this->get('indicator.volatility.weight', 0.10),
            'news' => (float) $this->get('indicator.news.weight', 0.05),
        ];
    }

    /**
     * Set indicator weights (with validation)
     */
    public function setIndicatorWeights(array $weights, ?int $updatedBy = null): void
    {
        // Validate weights sum to 1.0
        $sum = array_sum(array_values($weights));
        if (abs($sum - 1.0) > 0.01) {
            throw new \InvalidArgumentException("Indicator weights must sum to 1.0, got {$sum}");
        }

        foreach ($weights as $indicator => $weight) {
            $this->set("indicator.{$indicator}.weight", $weight, $updatedBy);
        }
    }

    /**
     * Get signal thresholds
     */
    public function getSignalThresholds(): array
    {
        return [
            'buy' => (int) $this->get('signal.buy_threshold', 70),
            'sell' => (int) $this->get('signal.sell_threshold', 30),
            'high_confidence' => (int) $this->get('signal.high_confidence_threshold', 85),
        ];
    }

    /**
     * Set signal thresholds
     */
    public function setSignalThresholds(array $thresholds, ?int $updatedBy = null): void
    {
        foreach ($thresholds as $type => $threshold) {
            if ($threshold < 0 || $threshold > 100) {
                throw new \InvalidArgumentException("Threshold must be between 0 and 100, got {$threshold}");
            }
            $this->set("signal.{$type}_threshold", $threshold, $updatedBy);
        }
    }

    /**
     * Get risk configuration
     */
    public function getRiskConfig(): array
    {
        return [
            'volatility' => [
                'low' => (int) $this->get('risk.volatility.low', 20),
                'medium' => (int) $this->get('risk.volatility.medium', 50),
                'high' => (int) $this->get('risk.volatility.high', 100),
            ],
            'liquidity' => [
                'minimum' => (int) $this->get('risk.liquidity.minimum', 40),
            ],
        ];
    }

    /**
     * Get notification configuration
     */
    public function getNotificationConfig(): array
    {
        return [
            'quiet_hours' => [
                'start' => $this->get('notification.quiet_hours.start', '22:00'),
                'end' => $this->get('notification.quiet_hours.end', '08:00'),
                'timezone' => $this->get('notification.quiet_hours.timezone', 'Africa/Cairo'),
            ],
            'rate_limit' => [
                'hourly' => (int) $this->get('notification.rate_limit.hourly', 5),
                'daily' => (int) $this->get('notification.rate_limit.daily', 20),
            ],
            'priority' => [
                'high_threshold' => (int) $this->get('notification.priority.high_threshold', 85),
            ],
        ];
    }

    /**
     * Extract category from setting key
     */
    private function extractCategory(string $key): string
    {
        $parts = explode('.', $key);
        return $parts[0] ?? 'app';
    }
}
