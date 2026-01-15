<?php

use App\Models\Signal;
use App\Models\Stock;

it('returns today signals', function () {
    $stock = Stock::factory()->create(['ticker' => 'COMI', 'name_ar' => 'البنك التجاري الدولي']);
    Signal::factory()->create([
        'stock_id' => $stock->id,
        'date' => now()->toDateString(),
        'type' => 'buy',
        'confidence' => 80,
        'risk_level' => 'low',
    ]);

    $response = $this->getJson('/api/v1/signals/today');

    $response->assertOk()->assertJsonStructure([
        ['id', 'stockName', 'stockSymbol', 'price', 'changePercent', 'signalType', 'confidence', 'riskLevel']
    ]);
});
