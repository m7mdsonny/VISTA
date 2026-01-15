<?php

namespace App\Services;

use App\Models\IndicatorDaily;
use Illuminate\Support\Collection;

class IndicatorService
{
    /**
     * @param array<int, array<string, mixed>> $dailyData
     */
    public function compute(array $dailyData): Collection
    {
        $grouped = collect($dailyData)->groupBy('stock_id');

        return $grouped->flatMap(function (Collection $candles, $stockId) {
            $sorted = $candles->sortBy('date')->values();
            $closingPrices = $sorted->pluck('close');
            $volumes = $sorted->pluck('volume');

            $rsi = $this->calculateRsi($closingPrices, 14);
            $ma20 = $this->movingAverage($closingPrices, 20);
            $ma50 = $this->movingAverage($closingPrices, 50);
            $ma200 = $this->movingAverage($closingPrices, 200);
            $vol20 = $this->volatility($closingPrices, 20);
            $vol60 = $this->volatility($closingPrices, 60);
            $avgVol20 = $this->movingAverage($volumes, 20);
            $avgVol60 = $this->movingAverage($volumes, 60);

            $latestDate = $sorted->last()['date'] ?? now()->toDateString();

            return collect([IndicatorDaily::updateOrCreate([
                'stock_id' => $stockId,
                'date' => $latestDate,
            ], [
                'rsi' => $rsi,
                'ma20' => $ma20,
                'ma50' => $ma50,
                'ma200' => $ma200,
                'vol20' => $vol20,
                'vol60' => $vol60,
                'avg_volume20' => $avgVol20,
                'avg_volume60' => $avgVol60,
            ])]);
        });
    }

    private function movingAverage(Collection $values, int $period): float
    {
        $slice = $values->take(-$period);
        if ($slice->count() === 0) {
            return 0.0;
        }
        return round($slice->average(), 2);
    }

    private function volatility(Collection $values, int $period): float
    {
        $slice = $values->take(-$period);
        if ($slice->count() === 0) {
            return 0.0;
        }
        $mean = $slice->average();
        $variance = $slice->map(fn ($v) => pow($v - $mean, 2))->average();
        return round(sqrt($variance), 4);
    }

    private function calculateRsi(Collection $values, int $period): float
    {
        if ($values->count() < $period + 1) {
            return 50.0;
        }

        $gains = 0.0;
        $losses = 0.0;
        $slice = $values->take(-($period + 1))->values();

        for ($i = 1; $i < $slice->count(); $i++) {
            $delta = $slice[$i] - $slice[$i - 1];
            if ($delta >= 0) {
                $gains += $delta;
            } else {
                $losses += abs($delta);
            }
        }

        $avgGain = $gains / $period;
        $avgLoss = $losses / $period;

        if ($avgLoss == 0.0) {
            return 100.0;
        }

        $rs = $avgGain / $avgLoss;
        $rsi = 100 - (100 / (1 + $rs));

        return round($rsi, 2);
    }
}
