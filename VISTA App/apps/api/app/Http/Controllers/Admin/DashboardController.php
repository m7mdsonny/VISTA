<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Signal;
use App\Models\User;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\DataQualityCheck;
use App\Models\AuditLog;
use App\Models\Entitlement;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // Active users with subscriptions
        $activeUsers = Subscription::where('status', 'active')
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->distinct('user_id')
            ->count('user_id');

        // Trial users
        $trialUsers = Subscription::where('status', 'trial')
            ->where('trial_ends_at', '>', now())
            ->distinct('user_id')
            ->count('user_id');

        // Signals today
        $todaySignals = Signal::whereDate('date', now()->toDateString())->count();

        // Data health (last 7 days)
        $last7Days = DataQualityCheck::where('checked_at', '>=', now()->subDays(7))
            ->where('is_accepted', true)
            ->count();
        $totalChecks = DataQualityCheck::where('checked_at', '>=', now()->subDays(7))->count();
        $dataHealth = $totalChecks > 0 ? round(($last7Days / $totalChecks) * 100, 1) : 0;

        // Monthly Recurring Revenue (MRR)
        $mrr = Subscription::where('status', 'active')
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->with('plan')
            ->get()
            ->sum(function ($subscription) {
                return $subscription->plan?->price_monthly ?? 0;
            });

        // Churn rate (last 30 days)
        $cancelled30Days = Subscription::where('status', 'cancelled')
            ->where('cancelled_at', '>=', now()->subDays(30))
            ->count();
        $totalActive30DaysAgo = Subscription::where('status', 'active')
            ->where('started_at', '<=', now()->subDays(30))
            ->count();
        $churnRate = $totalActive30DaysAgo > 0 ? round(($cancelled30Days / $totalActive30DaysAgo) * 100, 1) : 0;

        // User growth (last 30 days)
        $userGrowth = User::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->where('created_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Signal generation trend (last 7 days)
        $signalTrend = Signal::selectRaw('DATE(date) as date, COUNT(*) as count')
            ->where('date', '>=', now()->subDays(7)->toDateString())
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Subscription plan distribution
        $planDistribution = SubscriptionPlan::withCount([
            'subscriptions' => function ($query) {
                $query->where('status', 'active')
                    ->where(function ($q) {
                        $q->whereNull('expires_at')
                            ->orWhere('expires_at', '>', now());
                    });
            }
        ])->get();

        // Data quality trend (last 30 days)
        $qualityTrend = DataQualityCheck::selectRaw('DATE(checked_at) as date, AVG(quality_score) as avg_score')
            ->where('checked_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Recent activity (last 10 admin actions)
        $recentActivity = AuditLog::where('user_id', '!=', null)
            ->with('user:id,name,email')
            ->latest()
            ->limit(10)
            ->get();

        // Failed receipt verifications (alerts)
        $failedVerifications = Subscription::where('verification_failures', '>', 5)
            ->where('last_verified_at', '>=', now()->subDays(7))
            ->count();

        // Low data quality alerts
        $lowQualityAlerts = DataQualityCheck::where('quality_score', '<', 70)
            ->where('checked_at', '>=', now()->subDays(7))
            ->where('is_accepted', false)
            ->count();

        return view('admin.dashboard', compact(
            'activeUsers',
            'trialUsers',
            'todaySignals',
            'dataHealth',
            'mrr',
            'churnRate',
            'userGrowth',
            'signalTrend',
            'planDistribution',
            'qualityTrend',
            'recentActivity',
            'failedVerifications',
            'lowQualityAlerts'
        ));
    }
}

