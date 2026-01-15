<?php

use App\Services\IndicatorService;

it('calculates indicators from data', function () {
    $service = new IndicatorService();
    $dailyData = collect(range(1, 30))->map(function ($i) {
        return [
            'stock_id' => 1,
            'date' => now()->subDays(30 - $i)->toDateString(),
            'open' => 10 + $i,
            'high' => 10 + $i + 1,
            'low' => 10 + $i - 1,
            'close' => 10 + $i,
            'volume' => 1000 + $i,
        ];
    })->all();

    $result = $service->compute($dailyData);

    expect($result->count())->toBeGreaterThan(0);
});
