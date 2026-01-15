<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Signal;
use App\Models\User;
use App\Models\Subscription;

class DashboardController extends Controller
{
    public function index()
    {
        $todaySignals = Signal::whereDate('date', now()->toDateString())->count();
        $activeUsers = User::count();
        $subscriptions = Subscription::where('status', 'active')->count();

        return view('admin.dashboard', [
            'todaySignals' => $todaySignals,
            'activeUsers' => $activeUsers,
            'subscriptions' => $subscriptions,
        ]);
    }
}
