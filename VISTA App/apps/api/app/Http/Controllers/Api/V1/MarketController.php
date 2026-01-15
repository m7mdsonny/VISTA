<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;

class MarketController extends Controller
{
    public function summary()
    {
        return response()->json([
            'indexName' => 'EGX30',
            'value' => 28456.78,
            'change' => 234.56,
            'changePercent' => 0.83,
            'chartData' => [28100.0, 28200.0, 28150.0, 28300.0, 28250.0, 28400.0, 28456.78],
            'lastUpdate' => now()->format('H:i'),
        ]);
    }
}
