<?php

namespace App\Services\MarketData;

interface MarketDataProvider
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function fetchDailyCandles(): array;
}
