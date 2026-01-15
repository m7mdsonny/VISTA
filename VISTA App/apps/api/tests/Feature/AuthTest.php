<?php

use App\Models\User;
use Illuminate\Support\Facades\Hash;

it('allows user registration', function () {
    $response = $this->postJson('/api/v1/auth/register', [
        'name' => 'Vista User',
        'email' => 'user@example.com',
        'password' => 'Password123!',
        'password_confirmation' => 'Password123!',
    ]);

    $response->assertOk()->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);
});

it('allows user login', function () {
    $user = User::factory()->create([
        'email' => 'login@example.com',
        'password' => Hash::make('Password123!'),
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'email' => $user->email,
        'password' => 'Password123!',
    ]);

    $response->assertOk()->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);
});
