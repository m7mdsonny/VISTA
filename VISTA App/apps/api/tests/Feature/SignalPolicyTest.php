<?php

use App\Models\User;
use App\Models\Signal;
use Illuminate\Support\Facades\Gate;

it('prevents manual signal creation', function () {
    $user = User::factory()->create();
    $signal = Signal::factory()->create();

    expect(Gate::forUser($user)->allows('create', Signal::class))->toBeFalse();
    expect(Gate::forUser($user)->allows('update', $signal))->toBeFalse();
    expect(Gate::forUser($user)->allows('delete', $signal))->toBeFalse();
});
