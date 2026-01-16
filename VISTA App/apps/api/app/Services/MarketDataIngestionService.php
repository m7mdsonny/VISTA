<?php

namespace App\Services;

use App\Models\Stock;
use App\Models\CandleDaily;
use App\Services\DataQualityService;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MarketDataIngestionService
{
    public function __construct(
        private DataQualityService $dataQualityService
    ) {
    }

    /**
     * Ingest daily market data from external provider
     *
     * @param array<int, array<string, mixed>> $rawData Raw data from provider
     * @return Collection<CandleDaily> Ingested candles
     */
    public function ingest(array $rawData): Collection
    {
        $ingested = collect();

        foreach ($rawData as $row) {
            try {
                // Validate required fields
                if (!$this->validateRow($row)) {
                    Log::warning('Invalid row skipped', ['row' => $row]);
                    continue;
                }

                // Find or create stock
                $stock = Stock::firstOrCreate(
                    ['symbol' => $row['symbol']],
                    [
                        'name_ar' => $row['name_ar'] ?? $row['symbol'],
                        'sector' => $row['sector'] ?? null,
                        'is_active' => true,
                    ]
                );

                // Normalize and validate data
                $candleData = $this->normalizeRow($row, $stock->id);

                // Check data quality
                $qualityResult = $this->dataQualityService->evaluate([$candleData]);

                if (!$qualityResult->canPublish) {
                    Log::warning('Low quality data rejected', [
                        'stock_id' => $stock->id,
                        'score' => $qualityResult->score,
                        'anomalies' => $qualityResult->anomalies,
                    ]);
                    continue;
                }

                // Store candle data
                $candle = CandleDaily::updateOrCreate(
                    [
                        'stock_id' => $stock->id,
                        'date' => $candleData['date'],
                    ],
                    [
                        'open' => $candleData['open'],
                        'high' => $candleData['high'],
                        'low' => $candleData['low'],
                        'close' => $candleData['close'],
                        'volume' => $candleData['volume'],
                    ]
                );

                $ingested->push($candle);

            } catch (\Exception $e) {
                Log::error('Error ingesting market data', [
                    'row' => $row,
                    'error' => $e->getMessage(),
                ]);
                continue;
            }
        }

        return $ingested;
    }

    /**
     * Validate raw data row
     */
    private function validateRow(array $row): bool
    {
        $required = ['symbol', 'date', 'open', 'high', 'low', 'close', 'volume'];

        foreach ($required as $field) {
            if (!isset($row[$field]) || $row[$field] === null) {
                return false;
            }
        }

        // Validate numeric values
        $numericFields = ['open', 'high', 'low', 'close', 'volume'];
        foreach ($numericFields as $field) {
            if (!is_numeric($row[$field]) || $row[$field] < 0) {
                return false;
            }
        }

        // Validate OHLC logic (high >= low, high >= open, high >= close, etc.)
        if ($row['high'] < $row['low'] || $row['high'] < $row['open'] || $row['high'] < $row['close']) {
            return false;
        }

        if ($row['low'] > $row['open'] || $row['low'] > $row['close']) {
            return false;
        }

        return true;
    }

    /**
     * Normalize raw data row to standard format
     */
    private function normalizeRow(array $row, int $stockId): array
    {
        return [
            'stock_id' => $stockId,
            'date' => is_string($row['date']) ? \Carbon\Carbon::parse($row['date'])->toDateString() : $row['date'],
            'open' => (float) $row['open'],
            'high' => (float) $row['high'],
            'low' => (float) $row['low'],
            'close' => (float) $row['close'],
            'volume' => (int) $row['volume'],
        ];
    }

    /**
     * Ingest data for a specific stock
     */
    public function ingestForStock(Stock $stock, array $rawData): ?CandleDaily
    {
        $ingested = $this->ingest($rawData);

        return $ingested->firstWhere('stock_id', $stock->id);
    }

    /**
     * Ingest daily candle for a specific stock
     */
    public function ingestDailyCandle(string $symbol, \Carbon\Carbon $date, array $stockData): ?CandleDaily
    {
        // Find or create stock
        $stock = Stock::firstOrCreate(
            ['symbol' => $symbol],
            [
                'name_ar' => $stockData['name_ar'] ?? $symbol,
                'sector' => $stockData['sector'] ?? null,
                'is_active' => true,
            ]
        );

        // Prepare candle data
        $candleData = [
            'stock_id' => $stock->id,
            'date' => $date->toDateString(),
            'open' => (float) ($stockData['open'] ?? $stockData['price'] ?? 0),
            'high' => (float) ($stockData['high'] ?? $stockData['price'] ?? 0),
            'low' => (float) ($stockData['low'] ?? $stockData['price'] ?? 0),
            'close' => (float) ($stockData['close'] ?? $stockData['price'] ?? 0),
            'volume' => (int) ($stockData['volume'] ?? 0),
        ];

        // Validate row
        if (!$this->validateRow(array_merge($candleData, ['symbol' => $symbol]))) {
            \Illuminate\Support\Facades\Log::warning('Invalid candle data skipped', [
                'symbol' => $symbol,
                'date' => $date->toDateString(),
            ]);
            return null;
        }

        // Store candle
        return CandleDaily::updateOrCreate(
            [
                'stock_id' => $stock->id,
                'date' => $date->toDateString(),
            ],
            [
                'open' => $candleData['open'],
                'high' => $candleData['high'],
                'low' => $candleData['low'],
                'close' => $candleData['close'],
                'volume' => $candleData['volume'],
            ]
        );
    }
}
