<?php

namespace App\Policies;

use App\Models\Signal;
use App\Models\User;

class SignalPolicy
{
    public function create(User $user): bool
    {
        return false;
    }

    public function update(User $user, Signal $signal): bool
    {
        return false;
    }

    public function delete(User $user, Signal $signal): bool
    {
        return false;
    }
}
