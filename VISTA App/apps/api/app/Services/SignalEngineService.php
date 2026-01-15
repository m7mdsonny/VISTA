<?php

namespace App\Services;

use App\Models\Signal;
use App\Models\AdminSetting;
use Illuminate\Support\Collection;

class SignalEngineService
{
    /**
     * @param array<int, array<string, mixed>> $dailyData
     */
    public function generate(array $dailyData, Collection $indicators): Collection
    {
        $settings = AdminSetting::query()
            ->whereIn('key', ['analysis_weights', 'analysis_thresholds'])
            ->pluck('value_json', 'key');

        $thresholds = $settings->get('analysis_thresholds', [
            'rsi_oversold' => 30,
            'rsi_overbought' => 70,
            'volume_spike' => 1.5,
        ]);

        $latestByStock = collect($dailyData)->groupBy('stock_id')->map->last();

        return $indicators->map(function ($indicator) use ($thresholds, $latestByStock) {
            $latest = $latestByStock->get($indicator->stock_id);
            if (! $latest) {
                return null;
            }

            $signalType = 'hold';
            $confidence = 50;
            $signalLabel = 'monitor';

            if ($indicator->rsi <= $thresholds['rsi_oversold']) {
                $signalType = 'buy';
                $signalLabel = 'oversold';
                $confidence = 68;
            } elseif ($indicator->rsi >= $thresholds['rsi_overbought']) {
                $signalType = 'sell';
                $signalLabel = 'momentum';
                $confidence = 66;
            } elseif ($indicator->avg_volume20 > 0 && $latest['volume'] > ($indicator->avg_volume20 * $thresholds['volume_spike'])) {
                $signalType = 'buy';
                $signalLabel = 'volume';
                $confidence = 60;
            }

            $risk = $indicator->vol20 > $indicator->vol60 ? 'high' : 'medium';
            if ($indicator->vol20 < 0.5) {
                $risk = 'low';
            }

            return Signal::updateOrCreate([
                'stock_id' => $indicator->stock_id,
                'date' => $latest['date'],
            ], [
                'type' => $signalType,
                'confidence' => $confidence,
                'risk_level' => $risk,
                'status' => 'published',
                'source_version' => 'seeded-v1-'.$signalLabel,
            ]);
        })->filter();
    }
}
