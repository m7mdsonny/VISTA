<?php

namespace App\Services;

use App\Models\IndicatorDaily;
use App\Models\Stock;
use Illuminate\Support\Facades\Log;

class RiskAssessmentService
{
    /**
     * Assess risk level for a signal based on volatility and liquidity
     *
     * @param Stock $stock
     * @param IndicatorDaily|null $indicator
     * @return 'low'|'medium'|'high'
     */
    public function assess(Stock $stock, ?IndicatorDaily $indicator): string
    {
        if (!$indicator) {
            return 'medium'; // Default if no indicator data
        }

        $volatility = $indicator->volatility ?? 0;
        $liquidityScore = $indicator->liquidity_score ?? 50;

        // Get thresholds from admin settings (defaults)
        $volatilityLow = config('app.risk.volatility.low', 20);
        $volatilityMedium = config('app.risk.volatility.medium', 50);
        $liquidityMinimum = config('app.risk.liquidity.minimum', 40);

        // Assess volatility risk
        $volatilityRisk = 'medium';
        if ($volatility <= $volatilityLow) {
            $volatilityRisk = 'low';
        } elseif ($volatility >= $volatilityMedium) {
            $volatilityRisk = 'high';
        }

        // Assess liquidity risk
        $liquidityRisk = $liquidityScore >= $liquidityMinimum ? 'low' : 'high';

        // Combine risks (higher risk wins)
        if ($volatilityRisk === 'high' || $liquidityRisk === 'high') {
            return 'high';
        }

        if ($volatilityRisk === 'medium' || $liquidityRisk === 'medium') {
            return 'medium';
        }

        return 'low';
    }

    /**
     * Calculate liquidity score (0-100) based on volume and volume ratio
     */
    public function calculateLiquidityScore(IndicatorDaily $indicator): float
    {
        $volumeRatio = $indicator->volume_ratio ?? 1.0;
        $avgVolume20 = $indicator->volume_avg_20 ?? 0;

        // High volume ratio = better liquidity
        $volumeRatioScore = min(100, $volumeRatio * 50); // Max 100 at 2x average

        // Absolute volume matters too
        $volumeScore = min(100, log10(max($avgVolume20, 1)) * 20); // Logarithmic scale

        // Weighted average
        return ($volumeRatioScore * 0.6) + ($volumeScore * 0.4);
    }
}
