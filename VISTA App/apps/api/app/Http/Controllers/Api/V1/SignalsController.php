<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Signal;
use App\Models\CandleDaily;

class SignalsController extends Controller
{
    public function today()
    {
        $signals = Signal::with('stock')
            ->whereDate('date', now()->toDateString())
            ->orderByDesc('confidence')
            ->get();

        return response()->json($signals->map(fn (Signal $signal) => $this->mapSignal($signal)));
    }

    public function recent()
    {
        $signals = Signal::with('stock')
            ->orderByDesc('date')
            ->limit(20)
            ->get();

        return response()->json($signals->map(fn (Signal $signal) => $this->mapSignal($signal)));
    }

    public function show(string $id)
    {
        $signal = Signal::with(['stock', 'explanation'])->findOrFail($id);
        $candle = CandleDaily::where('stock_id', $signal->stock_id)
            ->orderByDesc('date')
            ->first();

        return response()->json([
            'id' => (string) $signal->id,
            'stockName' => $signal->stock?->name_ar,
            'stockSymbol' => $signal->stock?->ticker,
            'price' => $candle?->close ?? 0,
            'changePercent' => $this->changePercent($candle),
            'signalType' => $signal->type,
            'confidence' => $signal->confidence,
            'riskLevel' => $signal->risk_level,
            'targetPrice' => $candle ? round($candle->close * 1.08, 2) : 0,
            'stopLoss' => $candle ? round($candle->close * 0.94, 2) : 0,
            'reasons' => $signal->explanation?->why_json ?? [],
            'risks' => $signal->explanation?->caveats_json ?? [],
            'createdAt' => optional($signal->created_at)->format('Y-m-d H:i'),
        ]);
    }

    private function mapSignal(Signal $signal): array
    {
        $candle = CandleDaily::where('stock_id', $signal->stock_id)
            ->orderByDesc('date')
            ->first();

        return [
            'id' => (string) $signal->id,
            'stockName' => $signal->stock?->name_ar,
            'stockSymbol' => $signal->stock?->ticker,
            'price' => $candle?->close ?? 0,
            'changePercent' => $this->changePercent($candle),
            'signalType' => $signal->type,
            'confidence' => $signal->confidence,
            'riskLevel' => $signal->risk_level,
        ];
    }

    private function changePercent(?CandleDaily $candle): float
    {
        if (! $candle) {
            return 0.0;
        }
        $change = $candle->close - $candle->open;
        if ($candle->open == 0.0) {
            return 0.0;
        }

        return round(($change / $candle->open) * 100, 2);
    }
}
