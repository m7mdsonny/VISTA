<?php

namespace Tests\Unit;

use App\Models\User;
use App\Models\Signal;
use App\Policies\SignalPolicy;
use Tests\TestCase;

class SignalPolicyTest extends TestCase
{
    private SignalPolicy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        $this->policy = new SignalPolicy();
    }

    public function test_no_one_can_create_signals_manually(): void
    {
        $user = User::factory()->create();

        $canCreate = $this->policy->create($user);

        $this->assertFalse($canCreate);
    }

    public function test_no_one_can_update_signals_manually(): void
    {
        $user = User::factory()->create();
        $signal = Signal::factory()->create();

        $canUpdate = $this->policy->update($user, $signal);

        $this->assertFalse($canUpdate);
    }

    public function test_no_one_can_delete_signals_manually(): void
    {
        $user = User::factory()->create();
        $signal = Signal::factory()->create();

        $canDelete = $this->policy->delete($user, $signal);

        $this->assertFalse($canDelete);
    }

    public function test_admin_cannot_create_signals_either(): void
    {
        $admin = User::factory()->create();
        $admin->roles()->attach(\App\Models\Role::where('name', 'admin')->first()?->id);

        $canCreate = $this->policy->create($admin);

        // CRITICAL: Even admins cannot create signals manually
        $this->assertFalse($canCreate);
    }
}
