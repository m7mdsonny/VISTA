<?php

namespace App\Services;

use App\Models\Signal;
use App\Models\Stock;
use App\Models\CandleDaily;
use App\Models\NewsItem;
use App\Services\AdminConfigService;
use App\Services\RiskAssessmentService;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

class SignalEngineService
{
    public function __construct(
        private AdminConfigService $configService,
        private RiskAssessmentService $riskAssessment
    ) {
    }

    /**
     * Generate signals for all stocks based on market data
     * CRITICAL: This method reads ONLY market data and admin config, NEVER manual inputs
     */
    public function generateForDate(\Carbon\Carbon $date): Collection
    {
        // Get all active stocks with recent data
        $stocks = Stock::where('is_active', true)->get();

        $signals = collect();

        foreach ($stocks as $stock) {
            try {
                $signal = $this->generateSignalForStock($stock, $date);
                if ($signal) {
                    $signals->push($signal);
                }
            } catch (\Exception $e) {
                Log::error('Error generating signal for stock', [
                    'stock_id' => $stock->id,
                    'date' => $date->toDateString(),
                    'error' => $e->getMessage(),
                ]);
                continue;
            }
        }

        return $signals;
    }

    /**
     * Generate signal for a specific stock
     * CRITICAL: Automated only - no manual intervention
     */
    public function generateSignalForStock(Stock $stock, \Carbon\Carbon $date): ?Signal
    {
        // Get latest candle
        $candle = CandleDaily::where('stock_id', $stock->id)
            ->where('date', '<=', $date->toDateString())
            ->latest('date')
            ->first();

        if (!$candle) {
            return null; // No data available
        }

        // Get latest indicators
        $indicator = \App\Models\IndicatorDaily::where('stock_id', $stock->id)
            ->where('date', '<=', $date->toDateString())
            ->latest('date')
            ->first();

        if (!$indicator) {
            return null; // No indicators available
        }

        // Get news sentiment (if available)
        $newsImpact = $this->calculateNewsImpact($stock, $date);

        // Calculate confidence using weighted sum algorithm
        $weights = $this->configService->getIndicatorWeights();
        $confidence = $this->calculateConfidence($indicator, $candle, $newsImpact, $weights);

        // Get thresholds
        $thresholds = $this->configService->getSignalThresholds();

        // Determine signal type
        $signalType = 'hold';
        if ($confidence >= $thresholds['buy']) {
            $signalType = 'buy';
        } elseif ($confidence <= $thresholds['sell']) {
            $signalType = 'sell';
        }

        // Assess risk
        $riskLevel = $this->riskAssessment->assess($stock, $indicator);

        // Calculate target price and stop loss (optional)
        $targetPrice = $signalType === 'buy' ? $candle->close * 1.08 : null;
        $stopLoss = $signalType === 'buy' ? $candle->close * 0.94 : null;

        // Store calculation metadata for reproducibility
        $metadata = [
            'weights' => $weights,
            'thresholds' => $thresholds,
            'indicators' => [
                'rsi' => $indicator->rsi_14,
                'volume_ratio' => $indicator->volume_ratio,
                'liquidity_score' => $indicator->liquidity_score,
            ],
            'news_impact' => $newsImpact,
        ];

        // Create or update signal
        return Signal::updateOrCreate(
            [
                'stock_id' => $stock->id,
                'date' => $date->toDateString(),
            ],
            [
                'type' => $signalType, // Use 'type' to match database column
                'confidence' => (int) round($confidence),
                'risk_level' => $riskLevel,
                'price_at_signal' => $candle->close,
                'target_price' => $targetPrice,
                'stop_loss' => $stopLoss,
                'calculation_metadata' => $metadata,
                'status' => 'published',
            ]
        );
    }

    /**
     * Calculate signal confidence using weighted sum algorithm
     */
    private function calculateConfidence($indicator, $candle, float $newsImpact, array $weights): float
    {
        // Volume score (0-100)
        $volumeScore = $this->calculateVolumeScore($indicator, $candle);

        // Liquidity score (already in indicator, 0-100)
        $liquidityScore = $indicator->liquidity_score ?? 50;

        // Trend alignment (0-100)
        $trendScore = $this->calculateTrendScore($indicator);

        // Mean reversion score (0-100)
        $meanReversionScore = $this->calculateMeanReversionScore($indicator);

        // Volatility regime (0-100)
        $volatilityScore = $this->calculateVolatilityScore($indicator);

        // Weighted sum
        $confidence = (
            ($volumeScore * $weights['volume']) +
            ($liquidityScore * $weights['liquidity']) +
            ($trendScore * $weights['trend']) +
            ($meanReversionScore * $weights['mean_reversion']) +
            ($volatilityScore * $weights['volatility']) +
            ($newsImpact * $weights['news'])
        ) * 100; // Scale to 0-100

        // Clamp between 0-100
        return max(0, min(100, $confidence));
    }

    /**
     * Calculate volume score based on volume ratio
     */
    private function calculateVolumeScore($indicator, $candle): float
    {
        $volumeRatio = $indicator->volume_ratio ?? 1.0;

        // Score: 100 at 2x average, 50 at 1x, 0 at 0.5x
        if ($volumeRatio >= 2.0) {
            return 100;
        } elseif ($volumeRatio >= 1.0) {
            return 50 + (($volumeRatio - 1.0) * 50);
        } else {
            return max(0, $volumeRatio * 100);
        }
    }

    /**
     * Calculate trend alignment score
     */
    private function calculateTrendScore($indicator): float
    {
        // Compare price to moving averages
        // Simplified: if price > MA20 > MA50 > MA200, bullish trend
        // This would need actual price comparison, but for now use RSI as proxy
        $rsi = $indicator->rsi_14 ?? 50;

        // RSI 50 = neutral, 70+ = overbought (bearish), 30- = oversold (bullish)
        if ($rsi < 30) {
            return 80; // Oversold = potential bullish
        } elseif ($rsi > 70) {
            return 20; // Overbought = bearish
        } else {
            return 50; // Neutral
        }
    }

    /**
     * Calculate mean reversion score
     */
    private function calculateMeanReversionScore($indicator): float
    {
        // If price is far from moving average, mean reversion opportunity
        // Simplified version
        $rsi = $indicator->rsi_14 ?? 50;

        // Extreme RSI = mean reversion opportunity
        if ($rsi < 30 || $rsi > 70) {
            return 70; // Mean reversion opportunity
        }

        return 30; // Less mean reversion opportunity
    }

    /**
     * Calculate volatility regime score
     */
    private function calculateVolatilityScore($indicator): float
    {
        $volatility = $indicator->volatility ?? 0;

        // Low volatility = better for trending, high volatility = riskier
        // Invert: low volatility = higher score
        if ($volatility < 20) {
            return 80; // Low volatility = good
        } elseif ($volatility < 50) {
            return 50; // Medium volatility
        } else {
            return 20; // High volatility = risky
        }
    }

    /**
     * Calculate news impact score
     */
    private function calculateNewsImpact(Stock $stock, \Carbon\Carbon $date): float
    {
        // Get recent news (last 7 days)
        $newsItems = NewsItem::where('stock_id', $stock->id)
            ->where('published_at', '>=', $date->copy()->subDays(7))
            ->get();

        if ($newsItems->isEmpty()) {
            return 0; // No news impact
        }

        // Calculate weighted sentiment
        $totalImpact = 0;
        $count = 0;

        foreach ($newsItems as $news) {
            $impactScore = $news->impact_score ?? 50;
            $sentiment = $news->sentiment;

            // Convert sentiment to numeric (-1 to 1)
            $sentimentValue = match ($sentiment) {
                'positive' => 1.0,
                'negative' => -1.0,
                default => 0.0,
            };

            $totalImpact += ($impactScore / 100) * $sentimentValue;
            $count++;
        }

        if ($count === 0) {
            return 0;
        }

        // Average impact, normalized to -1 to 1, then to 0-1
        $avgImpact = $totalImpact / $count;
        return ($avgImpact + 1) / 2; // Convert -1..1 to 0..1
    }
}

