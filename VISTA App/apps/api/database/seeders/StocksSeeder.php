<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Stock;

class StocksSeeder extends Seeder
{
    public function run(): void
    {
        $stocks = [
            ['ticker' => 'COMI', 'name_ar' => 'البنك التجاري الدولي', 'sector_ar' => 'البنوك'],
            ['ticker' => 'ETEL', 'name_ar' => 'المصرية للاتصالات', 'sector_ar' => 'الاتصالات'],
            ['ticker' => 'TMGH', 'name_ar' => 'طلعت مصطفى القابضة', 'sector_ar' => 'العقارات'],
            ['ticker' => 'ESRS', 'name_ar' => 'السويدي إليكتريك', 'sector_ar' => 'الصناعة'],
            ['ticker' => 'ORHD', 'name_ar' => 'أوراسكوم للتنمية', 'sector_ar' => 'العقارات'],
            ['ticker' => 'FWRY', 'name_ar' => 'فوري', 'sector_ar' => 'الخدمات المالية'],
            ['ticker' => 'EFIH', 'name_ar' => 'إي إف جي القابضة', 'sector_ar' => 'الخدمات المالية'],
            ['ticker' => 'JUFO', 'name_ar' => 'جهينة للصناعات الغذائية', 'sector_ar' => 'الأغذية'],
        ];

        foreach ($stocks as $stock) {
            Stock::updateOrCreate(
                ['ticker' => $stock['ticker']],
                array_merge($stock, [
                    'is_active' => true,
                    'metadata' => [
                        'market_cap' => rand(10, 150) * 1_000_000_000,
                        'pe' => rand(8, 18),
                        'eps' => rand(200, 800) / 100,
                        'dividend' => rand(100, 400) / 100,
                    ],
                ])
            );
        }
    }
}
