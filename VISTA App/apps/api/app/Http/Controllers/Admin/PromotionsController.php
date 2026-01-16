<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Promotion;
use App\Models\SubscriptionPlan;
use App\Services\AdminConfigService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PromotionsController extends Controller
{
    public function __construct(
        private AdminConfigService $configService
    ) {
    }

    public function index(Request $request)
    {
        $query = Promotion::query();

        if ($request->has('status')) {
            if ($request->status === 'active') {
                $query->where('is_active', true)
                    ->where('starts_at', '<=', now())
                    ->where('ends_at', '>=', now());
            } elseif ($request->status === 'upcoming') {
                $query->where('is_active', true)
                    ->where('starts_at', '>', now());
            } elseif ($request->status === 'expired') {
                $query->where('ends_at', '<', now());
            }
        }

        $promotions = $query->latest('created_at')->paginate(20);
        $plans = SubscriptionPlan::where('is_active', true)->get();

        return view('admin.promotions.index', compact('promotions', 'plans'));
    }

    public function create()
    {
        $plans = SubscriptionPlan::where('is_active', true)->get();
        return view('admin.promotions.create', compact('plans'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|unique:promotions,code|max:50',
            'name_ar' => 'required|string|max:255',
            'name_en' => 'nullable|string|max:255',
            'description_ar' => 'nullable|string',
            'type' => 'required|in:percentage,fixed,free_trial',
            'discount_value' => 'required|numeric|min:0|max:100',
            'max_discount_amount' => 'nullable|numeric|min:0',
            'free_trial_days' => 'nullable|integer|min:1|max:365',
            'applies_to' => 'required|in:all,specific_plans',
            'applicable_plan_codes' => 'nullable|array',
            'frequency' => 'required|in:once,recurring',
            'usage_limit' => 'nullable|integer|min:1',
            'per_user_limit' => 'required|integer|min:1|max:10',
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after:starts_at',
            'minimum_plan_duration_months' => 'nullable|integer|min:1',
            'priority' => 'required|integer|min:0|max:100',
        ]);

        $promotion = Promotion::create($validated);

        // Log admin action
        \App\Models\AuditLog::create([
            'user_id' => Auth::id(),
            'action' => 'promotion.created',
            'resource_type' => 'Promotion',
            'resource_id' => $promotion->id,
            'new_values' => $validated,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return redirect()->route('admin.promotions.index')
            ->with('success', 'تم إنشاء العرض الترويجي بنجاح');
    }

    public function edit($id)
    {
        $promotion = Promotion::findOrFail($id);
        $plans = SubscriptionPlan::where('is_active', true)->get();
        return view('admin.promotions.edit', compact('promotion', 'plans'));
    }

    public function update(Request $request, $id)
    {
        $promotion = Promotion::findOrFail($id);

        $validated = $request->validate([
            'code' => 'required|string|max:50|unique:promotions,code,' . $id,
            'name_ar' => 'required|string|max:255',
            'name_en' => 'nullable|string|max:255',
            'description_ar' => 'nullable|string',
            'type' => 'required|in:percentage,fixed,free_trial',
            'discount_value' => 'required|numeric|min:0|max:100',
            'max_discount_amount' => 'nullable|numeric|min:0',
            'free_trial_days' => 'nullable|integer|min:1|max:365',
            'applies_to' => 'required|in:all,specific_plans',
            'applicable_plan_codes' => 'nullable|array',
            'frequency' => 'required|in:once,recurring',
            'usage_limit' => 'nullable|integer|min:1',
            'per_user_limit' => 'required|integer|min:1|max:10',
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after:starts_at',
            'minimum_plan_duration_months' => 'nullable|integer|min:1',
            'priority' => 'required|integer|min:0|max:100',
            'is_active' => 'boolean',
        ]);

        $oldValues = $promotion->toArray();
        $promotion->update($validated);

        // Log admin action
        \App\Models\AuditLog::create([
            'user_id' => Auth::id(),
            'action' => 'promotion.updated',
            'resource_type' => 'Promotion',
            'resource_id' => $promotion->id,
            'old_values' => $oldValues,
            'new_values' => $validated,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return redirect()->route('admin.promotions.index')
            ->with('success', 'تم تحديث العرض الترويجي بنجاح');
    }

    public function toggle($id)
    {
        $promotion = Promotion::findOrFail($id);
        $promotion->update(['is_active' => !$promotion->is_active]);

        return back()->with('success', $promotion->is_active ? 'تم تفعيل العرض' : 'تم تعطيل العرض');
    }
}
