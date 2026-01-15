<?php

use App\Services\ExplainabilityService;
use App\Models\Signal;
use Illuminate\Support\Collection;

it('generates explainability with fixed lengths', function () {
    $service = new ExplainabilityService();

    $signal = new Signal([
        'id' => 1,
        'stock_id' => 1,
        'type' => 'buy',
        'confidence' => 80,
        'risk_level' => 'low',
    ]);

    $signals = new Collection([$signal]);
    $indicators = new Collection();

    $explanations = $service->attach($signals, $indicators);

    $explanation = $explanations->first();
    expect($explanation->why_json)->toHaveCount(3);
    expect($explanation->caveats_json)->toHaveCount(2);
});
