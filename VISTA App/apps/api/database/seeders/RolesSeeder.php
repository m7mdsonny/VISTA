<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        Role::updateOrCreate(['name' => 'admin'], ['label_ar' => 'مسؤول']);
        Role::updateOrCreate(['name' => 'super_admin'], ['label_ar' => 'مسؤول أعلى']);
        Role::updateOrCreate(['name' => 'user'], ['label_ar' => 'مستخدم']);
    }
}
