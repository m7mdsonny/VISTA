<?php

namespace App\Services\MarketData;

use App\Models\CandleDaily;

class SeededProvider implements MarketDataProvider
{
    public function fetchDailyCandles(): array
    {
        return CandleDaily::query()
            ->with('stock')
            ->orderBy('date', 'desc')
            ->limit(500)
            ->get()
            ->map(fn (CandleDaily $candle) => [
                'stock_id' => $candle->stock_id,
                'ticker' => optional($candle->stock)->ticker,
                'date' => $candle->date->toDateString(),
                'open' => $candle->open,
                'high' => $candle->high,
                'low' => $candle->low,
                'close' => $candle->close,
                'volume' => $candle->volume,
            ])
            ->all();
    }
}
