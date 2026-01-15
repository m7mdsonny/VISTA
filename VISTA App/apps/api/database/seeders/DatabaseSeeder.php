<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RolesSeeder::class,
            StocksSeeder::class,
            FundsSeeder::class,
            CandlesSeeder::class,
            PlansSeeder::class,
            SignalsSeeder::class,
            AdminSettingsSeeder::class,
        ]);
    }
}
