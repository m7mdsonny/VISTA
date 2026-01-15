<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PlansController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\Admin\UsersController;

Route::get('/', function () {
    return response()->json(['message' => 'Vista API']);
});

Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/plans', [PlansController::class, 'index'])->name('plans.index');
    Route::get('/plans/{id}/edit', [PlansController::class, 'edit'])->name('plans.edit');
    Route::put('/plans/{id}', [PlansController::class, 'update'])->name('plans.update');
    Route::get('/settings', [SettingsController::class, 'edit'])->name('settings.edit');
    Route::put('/settings', [SettingsController::class, 'update'])->name('settings.update');
    Route::get('/users', [UsersController::class, 'index'])->name('users.index');
});
