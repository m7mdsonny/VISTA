<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Models\AuditLog;
use Illuminate\Http\Request;

class PlansController extends Controller
{
    public function index()
    {
        $plans = SubscriptionPlan::orderBy('sort')->get();

        return view('admin.plans.index', ['plans' => $plans]);
    }

    public function edit(string $id)
    {
        $plan = SubscriptionPlan::findOrFail($id);

        return view('admin.plans.edit', ['plan' => $plan]);
    }

    public function update(Request $request, string $id)
    {
        $plan = SubscriptionPlan::findOrFail($id);
        $data = $request->validate([
            'name_ar' => ['required', 'string'],
            'price_display_ar' => ['nullable', 'string'],
            'is_active' => ['nullable'],
            'features_json' => ['nullable', 'string'],
            'sort' => ['nullable', 'integer'],
        ]);

        $features = $data['features_json'] ? json_decode($data['features_json'], true) : $plan->features_json;

        $plan->update([
            'name_ar' => $data['name_ar'],
            'price_display_ar' => $data['price_display_ar'] ?? $plan->price_display_ar,
            'is_active' => isset($data['is_active']),
            'features_json' => $features,
            'sort' => $data['sort'] ?? $plan->sort,
        ]);

        $this->logAudit('update', 'subscription_plan', (string) $plan->id, $data);

        return redirect()->route('admin.plans.index')->with('status', 'تم تحديث الخطة');
    }

    private function logAudit(string $action, string $entity, string $entityId, array $diff): void
    {
        AuditLog::create([
            'actor_user_id' => request()->user()?->id,
            'action' => $action,
            'entity' => $entity,
            'entity_id' => $entityId,
            'diff_json' => $diff,
            'ip' => request()->ip(),
            'ua' => request()->userAgent(),
        ]);
    }
}
