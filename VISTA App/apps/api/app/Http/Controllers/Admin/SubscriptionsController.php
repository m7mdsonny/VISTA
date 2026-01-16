<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;

class SubscriptionsController extends Controller
{
    public function index(Request $request)
    {
        $query = Subscription::with(['user:id,name,email', 'plan:id,code,name_ar']);

        // Filters
        if ($request->has('plan_id')) {
            $query->where('plan_id', $request->plan_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('platform')) {
            $query->where('platform', $request->platform);
        }

        $subscriptions = $query->latest('started_at')->paginate(50);

        $plans = SubscriptionPlan::where('is_active', true)->get();

        return view('admin.subscriptions.index', compact('subscriptions', 'plans'));
    }

    public function show($id)
    {
        $subscription = Subscription::with(['user', 'plan', 'invoices'])
            ->findOrFail($id);

        return view('admin.subscriptions.show', compact('subscription'));
    }
}
