<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Stock;
use App\Models\CandleDaily;

class CandlesSeeder extends Seeder
{
    public function run(): void
    {
        $days = 120;
        $stocks = Stock::all();

        foreach ($stocks as $stock) {
            $basePrice = rand(800, 2000) / 10;

            for ($i = $days; $i >= 0; $i--) {
                $date = now()->subDays($i)->toDateString();
                $open = $basePrice + rand(-50, 50) / 10;
                $close = $open + rand(-30, 30) / 10;
                $high = max($open, $close) + rand(0, 20) / 10;
                $low = min($open, $close) - rand(0, 20) / 10;
                $volume = rand(500000, 3500000);

                CandleDaily::updateOrCreate([
                    'stock_id' => $stock->id,
                    'date' => $date,
                ], [
                    'open' => round($open, 2),
                    'high' => round($high, 2),
                    'low' => round($low, 2),
                    'close' => round($close, 2),
                    'volume' => $volume,
                ]);

                $basePrice = $close;
            }
        }
    }
}
