<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Subscription;

class UsersController extends Controller
{
    public function index()
    {
        $users = User::with('roles')->orderByDesc('created_at')->get();
        $subscriptions = Subscription::orderByDesc('created_at')->get()->groupBy('user_id');

        return view('admin.users.index', [
            'users' => $users,
            'subscriptions' => $subscriptions,
        ]);
    }
}
