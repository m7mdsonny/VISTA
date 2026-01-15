<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\MarketController;
use App\Http\Controllers\Api\V1\SignalsController;
use App\Http\Controllers\Api\V1\StocksController;
use App\Http\Controllers\Api\V1\FundsController;
use App\Http\Controllers\Api\V1\WatchlistsController;
use App\Http\Controllers\Api\V1\AlertsController;
use App\Http\Controllers\Api\V1\SubscriptionController;
use App\Http\Controllers\Api\V1\WebhookController;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::middleware('auth:sanctum')->group(function () {
            Route::get('me', [AuthController::class, 'me']);
            Route::post('logout', [AuthController::class, 'logout']);
        });
    });

    Route::get('market/summary', [MarketController::class, 'summary']);

    Route::get('signals/today', [SignalsController::class, 'today']);
    Route::get('signals/recent', [SignalsController::class, 'recent']);
    Route::get('signals/{id}', [SignalsController::class, 'show']);

    Route::get('stocks', [StocksController::class, 'index']);
    Route::get('stocks/{symbol}', [StocksController::class, 'show']);
    Route::get('stocks/{symbol}/candles', [StocksController::class, 'candles']);
    Route::get('stocks/{symbol}/signals', [StocksController::class, 'signals']);

    Route::get('funds', [FundsController::class, 'index']);
    Route::get('funds/{id}', [FundsController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('watchlists', [WatchlistsController::class, 'index']);
        Route::post('watchlists', [WatchlistsController::class, 'store']);
        Route::put('watchlists/{id}', [WatchlistsController::class, 'update']);
        Route::delete('watchlists/{id}', [WatchlistsController::class, 'destroy']);
        Route::post('watchlists/{id}/items', [WatchlistsController::class, 'addItem']);
        Route::delete('watchlists/{id}/items/{itemId}', [WatchlistsController::class, 'removeItem']);

        Route::get('alerts', [AlertsController::class, 'index']);
        Route::put('alerts/{id}/read', [AlertsController::class, 'markRead']);

        Route::get('subscription/status', [SubscriptionController::class, 'status']);
        Route::post('subscription/verify/apple', [SubscriptionController::class, 'verifyApple'])
            ->middleware('throttle:6,1');
        Route::post('subscription/verify/google', [SubscriptionController::class, 'verifyGoogle'])
            ->middleware('throttle:6,1');
    });

    Route::post('webhooks/apple', [WebhookController::class, 'apple']);
    Route::post('webhooks/google', [WebhookController::class, 'google']);
});
