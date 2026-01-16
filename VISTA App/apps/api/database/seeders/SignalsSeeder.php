<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Stock;
use App\Models\Signal;
use App\Models\SignalExplanation;

class SignalsSeeder extends Seeder
{
    public function run(): void
    {
        $stocks = Stock::take(4)->get();

        foreach ($stocks as $stock) {
            $signal = Signal::updateOrCreate([
                'stock_id' => $stock->id,
                'date' => now()->toDateString(),
            ], [
                'type' => 'buy',
                'confidence' => rand(65, 88),
                'risk_level' => 'medium',
                'status' => 'published',
                'source_version' => 'seeded-v1',
            ]);

            SignalExplanation::updateOrCreate([
                'signal_id' => $signal->id,
            ], [
                'why_json' => [
                    'زيادة في حجم التداول مقارنة بمتوسط آخر 20 جلسة',
                    'تحسن تدريجي في الزخم الفني',
                    'السعر قريب من مستوى دعم مهم',
                ],
                'caveats_json' => [
                    'تقلبات السوق العامة قد تؤثر على الأداء',
                    'الإشارة ليست ضماناً وتحتاج متابعة',
                ],
                'summary_ar' => 'إشارة متابعة مع ثقة معتدلة',
            ]);
        }
    }
}
