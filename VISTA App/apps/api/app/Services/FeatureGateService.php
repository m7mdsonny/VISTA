<?php

namespace App\Services;

use App\Models\User;
use App\Models\Entitlement;
use App\Models\Subscription;

class FeatureGateService
{
    /**
     * Check if user has access to a feature
     */
    public function canAccess(User $user, string $featureKey): bool
    {
        // Check global feature flag (admin settings)
        $globalEnabled = \App\Models\AdminSetting::where('key', "app.features.{$featureKey}")
            ->value('value');

        if ($globalEnabled === false || $globalEnabled === 'false') {
            return false; // Feature disabled globally
        }

        // Get user's entitlements
        $entitlement = Entitlement::where('user_id', $user->id)
            ->where('feature_key', $featureKey)
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->first();

        if (!$entitlement) {
            // Check if user has active subscription with this feature
            $subscription = Subscription::where('user_id', $user->id)
                ->where('status', 'active')
                ->where(function ($query) {
                    $query->whereNull('expires_at')
                        ->orWhere('expires_at', '>', now());
                })
                ->with('plan')
                ->first();

            if ($subscription && $subscription->plan) {
                $features = $subscription->plan->features ?? [];
                return isset($features[$featureKey]) && $features[$featureKey] === true;
            }

            return false;
        }

        // Check entitlement value
        if ($entitlement->feature_value === 'true' || $entitlement->feature_value === true) {
            return true;
        }

        if ($entitlement->feature_value === 'false' || $entitlement->feature_value === false) {
            return false;
        }

        // Numeric values (e.g., watchlist count)
        return is_numeric($entitlement->feature_value) && (int) $entitlement->feature_value > 0;
    }

    /**
     * Get feature value (for numeric limits, e.g., watchlist count)
     */
    public function getFeatureValue(User $user, string $featureKey): mixed
    {
        $entitlement = Entitlement::where('user_id', $user->id)
            ->where('feature_key', $featureKey)
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->first();

        if (!$entitlement) {
            // Check subscription plan
            $subscription = Subscription::where('user_id', $user->id)
                ->where('status', 'active')
                ->with('plan')
                ->first();

            if ($subscription && $subscription->plan) {
                $features = $subscription->plan->features ?? [];
                return $features[$featureKey] ?? null;
            }

            return null;
        }

        // Convert string values
        if ($entitlement->feature_value === 'true') {
            return true;
        }

        if ($entitlement->feature_value === 'false') {
            return false;
        }

        // Return numeric or string value
        return is_numeric($entitlement->feature_value)
            ? (int) $entitlement->feature_value
            : $entitlement->feature_value;
    }

    /**
     * Check if user can perform action (e.g., create watchlist)
     */
    public function canPerformAction(User $user, string $action, int $currentCount = 0): bool
    {
        $featureKey = match ($action) {
            'create_watchlist' => 'watchlists',
            'create_alert' => 'alerts',
            default => $action,
        };

        $limit = $this->getFeatureValue($user, $featureKey);

        // -1 means unlimited
        if ($limit === -1) {
            return true;
        }

        // No limit set or 0 means not allowed
        if (!$limit || $limit === 0) {
            return false;
        }

        // Check if within limit
        return $currentCount < $limit;
    }
}
