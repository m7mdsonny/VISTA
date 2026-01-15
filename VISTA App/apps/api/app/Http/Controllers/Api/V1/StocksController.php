<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Stock;
use App\Models\CandleDaily;
use App\Models\Signal;

class StocksController extends Controller
{
    public function index()
    {
        $stocks = Stock::where('is_active', true)->get();

        return response()->json($stocks->map(function (Stock $stock) {
            $latest = CandleDaily::where('stock_id', $stock->id)->orderByDesc('date')->first();
            $chart = CandleDaily::where('stock_id', $stock->id)
                ->orderByDesc('date')
                ->limit(5)
                ->pluck('close')
                ->reverse()
                ->values();

            return [
                'symbol' => $stock->ticker,
                'name' => $stock->name_ar,
                'price' => $latest?->close ?? 0,
                'change' => $this->changePercent($latest),
                'sector' => $stock->sector_ar,
                'chart' => $chart,
            ];
        }));
    }

    public function show(string $symbol)
    {
        $stock = Stock::where('ticker', $symbol)->firstOrFail();
        $latest = CandleDaily::where('stock_id', $stock->id)->orderByDesc('date')->first();

        return response()->json([
            'name' => $stock->name_ar,
            'symbol' => $stock->ticker,
            'price' => $latest?->close ?? 0,
            'change' => $latest ? round($latest->close - $latest->open, 2) : 0,
            'changePercent' => $this->changePercent($latest),
            'open' => $latest?->open ?? 0,
            'high' => $latest?->high ?? 0,
            'low' => $latest?->low ?? 0,
            'close' => $latest?->close ?? 0,
            'volume' => $latest?->volume ?? 0,
            'marketCap' => $stock->metadata['market_cap'] ?? 0,
            'pe' => $stock->metadata['pe'] ?? 0,
            'eps' => $stock->metadata['eps'] ?? 0,
            'dividend' => $stock->metadata['dividend'] ?? 0,
            'sector' => $stock->sector_ar,
            'chartData' => CandleDaily::where('stock_id', $stock->id)
                ->orderByDesc('date')
                ->limit(7)
                ->pluck('close')
                ->reverse()
                ->values(),
        ]);
    }

    public function candles(string $symbol)
    {
        $stock = Stock::where('ticker', $symbol)->firstOrFail();
        $range = request()->query('range', '1m');
        $days = match ($range) {
            '3m' => 90,
            '6m' => 180,
            '1y' => 365,
            default => 30,
        };

        $candles = CandleDaily::where('stock_id', $stock->id)
            ->orderByDesc('date')
            ->limit($days)
            ->get()
            ->map(fn (CandleDaily $candle) => [
                'date' => $candle->date->toDateString(),
                'open' => $candle->open,
                'high' => $candle->high,
                'low' => $candle->low,
                'close' => $candle->close,
                'volume' => $candle->volume,
            ])
            ->reverse()
            ->values();

        return response()->json([
            'symbol' => $stock->ticker,
            'range' => $range,
            'candles' => $candles,
        ]);
    }

    public function signals(string $symbol)
    {
        $stock = Stock::where('ticker', $symbol)->firstOrFail();
        $signals = Signal::where('stock_id', $stock->id)->orderByDesc('date')->get();

        return response()->json($signals->map(function (Signal $signal) use ($stock) {
            $candle = CandleDaily::where('stock_id', $stock->id)->orderByDesc('date')->first();

            return [
                'id' => (string) $signal->id,
                'stockName' => $stock->name_ar,
                'stockSymbol' => $stock->ticker,
                'price' => $candle?->close ?? 0,
                'changePercent' => $this->changePercent($candle),
                'signalType' => $signal->type,
                'confidence' => $signal->confidence,
                'riskLevel' => $signal->risk_level,
            ];
        }));
    }

    private function changePercent(?CandleDaily $candle): float
    {
        if (! $candle || $candle->open == 0.0) {
            return 0.0;
        }

        return round((($candle->close - $candle->open) / $candle->open) * 100, 2);
    }
}
