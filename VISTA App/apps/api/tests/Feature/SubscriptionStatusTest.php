<?php

use App\Models\User;
use Laravel\Sanctum\Sanctum;

it('returns subscription status for authenticated user', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user);

    $response = $this->getJson('/api/v1/subscription/status');

    $response->assertOk()->assertJsonStructure([
        'plan' => ['code', 'name', 'isActive'],
        'entitlements',
        'trial' => ['isActive', 'daysRemaining'],
    ]);
});
