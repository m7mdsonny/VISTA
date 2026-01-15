<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Fund;

class FundsSeeder extends Seeder
{
    public function run(): void
    {
        $funds = [
            ['name_ar' => 'صندوق بنك مصر', 'type_ar' => 'أسهم'],
            ['name_ar' => 'صندوق CIB', 'type_ar' => 'متوازن'],
            ['name_ar' => 'صندوق الأهلي', 'type_ar' => 'أسهم'],
            ['name_ar' => 'صندوق QNB', 'type_ar' => 'سندات'],
        ];

        foreach ($funds as $fund) {
            Fund::updateOrCreate(
                ['name_ar' => $fund['name_ar']],
                array_merge($fund, [
                    'is_active' => true,
                    'metadata' => [
                        'nav' => rand(900, 1600) / 10,
                        'change' => rand(-50, 50) / 10,
                    ],
                ])
            );
        }
    }
}
