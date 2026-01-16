<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PlansController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\Admin\UsersController;
use App\Http\Controllers\Admin\SubscriptionsController;
use App\Http\Controllers\Admin\InvoicesController;
use App\Http\Controllers\Admin\AnalysisConfigController;
use App\Http\Controllers\Admin\StocksController;
use App\Http\Controllers\Admin\FundsController;
use App\Http\Controllers\Admin\NotificationsController;
use App\Http\Controllers\Admin\AppConfigController;
use App\Http\Controllers\Admin\DataQualityController;
use App\Http\Controllers\Admin\AuditLogsController;
use App\Http\Controllers\Admin\AuthController as AdminAuthController;

Route::get('/', function () {
    return response()->json(['message' => 'Vista API']);
});

// Admin authentication
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.post');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
});

// Admin routes (protected)
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Subscription Management
    Route::prefix('subscriptions')->name('subscriptions.')->group(function () {
        Route::resource('plans', PlansController::class)->except(['create', 'destroy']);
        Route::get('/subscriptions', [SubscriptionsController::class, 'index'])->name('index');
        Route::get('/subscriptions/{id}', [SubscriptionsController::class, 'show'])->name('show');
        Route::get('/invoices', [InvoicesController::class, 'index'])->name('invoices.index');
        Route::get('/invoices/{id}', [InvoicesController::class, 'show'])->name('invoices.show');
    });

    // Analysis Configuration
    Route::prefix('analysis')->name('analysis.')->group(function () {
        Route::get('/weights', [AnalysisConfigController::class, 'weights'])->name('weights');
        Route::put('/weights', [AnalysisConfigController::class, 'updateWeights'])->name('weights.update');
        Route::get('/thresholds', [AnalysisConfigController::class, 'thresholds'])->name('thresholds');
        Route::put('/thresholds', [AnalysisConfigController::class, 'updateThresholds'])->name('thresholds.update');
        Route::get('/risk', [AnalysisConfigController::class, 'risk'])->name('risk');
        Route::put('/risk', [AnalysisConfigController::class, 'updateRisk'])->name('risk.update');
        Route::get('/liquidity', [AnalysisConfigController::class, 'liquidity'])->name('liquidity');
        Route::put('/liquidity', [AnalysisConfigController::class, 'updateLiquidity'])->name('liquidity.update');
    });

    // Stocks & Funds
    Route::prefix('stocks')->name('stocks.')->group(function () {
        Route::get('/', [StocksController::class, 'index'])->name('index');
        Route::get('/{id}', [StocksController::class, 'show'])->name('show');
        Route::put('/{id}', [StocksController::class, 'update'])->name('update');
        Route::put('/{id}/toggle', [StocksController::class, 'toggle'])->name('toggle');
    });

    Route::prefix('funds')->name('funds.')->group(function () {
        Route::get('/', [FundsController::class, 'index'])->name('index');
        Route::get('/{id}', [FundsController::class, 'show'])->name('show');
        Route::put('/{id}', [FundsController::class, 'update'])->name('update');
    });

    // Notifications Control
    Route::prefix('notifications')->name('notifications.')->group(function () {
        Route::get('/types', [NotificationsController::class, 'types'])->name('types');
        Route::put('/types', [NotificationsController::class, 'updateTypes'])->name('types.update');
        Route::get('/priority', [NotificationsController::class, 'priority'])->name('priority');
        Route::put('/priority', [NotificationsController::class, 'updatePriority'])->name('priority.update');
        Route::get('/quiet-hours', [NotificationsController::class, 'quietHours'])->name('quiet-hours');
        Route::put('/quiet-hours', [NotificationsController::class, 'updateQuietHours'])->name('quiet-hours.update');
        Route::get('/rate-limits', [NotificationsController::class, 'rateLimits'])->name('rate-limits');
        Route::put('/rate-limits', [NotificationsController::class, 'updateRateLimits'])->name('rate-limits.update');
    });

    // App Configuration
    Route::prefix('app')->name('app.')->group(function () {
        Route::get('/features', [AppConfigController::class, 'features'])->name('features');
        Route::put('/features', [AppConfigController::class, 'updateFeatures'])->name('features.update');
        Route::get('/maintenance', [AppConfigController::class, 'maintenance'])->name('maintenance');
        Route::put('/maintenance', [AppConfigController::class, 'updateMaintenance'])->name('maintenance.update');
        Route::get('/legal', [AppConfigController::class, 'legal'])->name('legal');
        Route::put('/legal', [AppConfigController::class, 'updateLegal'])->name('legal.update');
    });

    // Promotions Management
    Route::prefix('promotions')->name('promotions.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\PromotionsController::class, 'index'])->name('index');
        Route::get('/create', [\App\Http\Controllers\Admin\PromotionsController::class, 'create'])->name('create');
        Route::post('/', [\App\Http\Controllers\Admin\PromotionsController::class, 'store'])->name('store');
        Route::get('/{id}/edit', [\App\Http\Controllers\Admin\PromotionsController::class, 'edit'])->name('edit');
        Route::put('/{id}', [\App\Http\Controllers\Admin\PromotionsController::class, 'update'])->name('update');
        Route::put('/{id}/toggle', [\App\Http\Controllers\Admin\PromotionsController::class, 'toggle'])->name('toggle');
    });

    // API Providers Management
    Route::prefix('api-providers')->name('api-providers.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'index'])->name('index');
        Route::get('/create', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'create'])->name('create');
        Route::post('/', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'store'])->name('store');
        Route::get('/{id}/edit', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'edit'])->name('edit');
        Route::put('/{id}', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'update'])->name('update');
        Route::post('/{id}/test', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'test'])->name('test');
        Route::get('/{id}/logs', [\App\Http\Controllers\Admin\ApiProvidersController::class, 'logs'])->name('logs');
    });

    // Data Quality
    Route::prefix('data-quality')->name('data-quality.')->group(function () {
        Route::get('/', [DataQualityController::class, 'index'])->name('index');
        Route::get('/checks', [DataQualityController::class, 'checks'])->name('checks');
        Route::get('/checks/{id}', [DataQualityController::class, 'showCheck'])->name('checks.show');
    });

    // Security & Logs
    Route::prefix('security')->name('security.')->group(function () {
        Route::get('/audit-logs', [AuditLogsController::class, 'index'])->name('audit-logs.index');
        Route::get('/audit-logs/{id}', [AuditLogsController::class, 'show'])->name('audit-logs.show');
        Route::get('/failed-verifications', [AuditLogsController::class, 'failedVerifications'])->name('failed-verifications');
        Route::get('/admin-actions', [AuditLogsController::class, 'adminActions'])->name('admin-actions');
    });

    // Settings (legacy - keeping for backward compatibility)
    Route::get('/settings', [SettingsController::class, 'edit'])->name('settings.edit');
    Route::put('/settings', [SettingsController::class, 'update'])->name('settings.update');

    // Users (legacy)
    Route::get('/users', [UsersController::class, 'index'])->name('users.index');
});
