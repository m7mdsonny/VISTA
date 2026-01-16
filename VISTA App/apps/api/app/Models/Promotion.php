<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Subscription;

class Promotion extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name_ar',
        'name_en',
        'description_ar',
        'type',
        'discount_value',
        'max_discount_amount',
        'free_trial_days',
        'applies_to',
        'applicable_plan_codes',
        'frequency',
        'usage_limit',
        'usage_count',
        'per_user_limit',
        'starts_at',
        'ends_at',
        'is_active',
        'minimum_plan_duration_months',
        'priority',
    ];

    protected $casts = [
        'discount_value' => 'decimal:2',
        'max_discount_amount' => 'decimal:2',
        'applicable_plan_codes' => 'array',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'is_active' => 'boolean',
        'usage_count' => 'integer',
        'per_user_limit' => 'integer',
        'minimum_plan_duration_months' => 'integer',
        'priority' => 'integer',
    ];

    public function userPromotions()
    {
        return $this->hasMany(UserPromotion::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    /**
     * Check if promotion is currently active
     */
    public function isActiveNow(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        $now = now();
        return $now->gte($this->starts_at) && $now->lte($this->ends_at);
    }

    /**
     * Check if promotion has reached usage limit
     */
    public function hasReachedLimit(): bool
    {
        if ($this->usage_limit === null) {
            return false; // Unlimited
        }

        return $this->usage_count >= $this->usage_limit;
    }

    /**
     * Check if user can use this promotion
     */
    public function canBeUsedBy(User $user, ?string $planCode = null): array
    {
        $canUse = true;
        $reason = null;

        // Check if active
        if (!$this->isActiveNow()) {
            return [
                'can_use' => false,
                'reason' => 'العرض غير نشط حالياً',
            ];
        }

        // Check usage limit
        if ($this->hasReachedLimit()) {
            return [
                'can_use' => false,
                'reason' => 'تم الوصول إلى الحد الأقصى لاستخدام هذا العرض',
            ];
        }

        // Check per-user limit
        $userUsageCount = UserPromotion::where('user_id', $user->id)
            ->where('promotion_id', $this->id)
            ->count();

        if ($userUsageCount >= $this->per_user_limit) {
            return [
                'can_use' => false,
                'reason' => 'تم استخدام هذا العرض بالفعل',
            ];
        }

        // Check if applies to this plan
        if ($this->applies_to === 'specific_plans' && $planCode) {
            $applicablePlans = $this->applicable_plan_codes ?? [];
            if (!in_array($planCode, $applicablePlans)) {
                return [
                    'can_use' => false,
                    'reason' => 'هذا العرض غير متاح لهذه الخطة',
                ];
            }
        }

        return [
            'can_use' => true,
            'reason' => null,
        ];
    }

    /**
     * Calculate discount for a given price
     */
    public function calculateDiscount(float $originalPrice): float
    {
        if ($this->type === 'percentage') {
            $discount = ($originalPrice * $this->discount_value) / 100;
            
            // Apply max discount cap if set
            if ($this->max_discount_amount && $discount > $this->max_discount_amount) {
                $discount = $this->max_discount_amount;
            }
            
            return $discount;
        }

        if ($this->type === 'fixed') {
            return min($this->discount_value, $originalPrice); // Can't discount more than price
        }

        return 0; // free_trial doesn't reduce price, extends trial
    }
}
