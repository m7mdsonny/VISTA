<?php

namespace App\Services;

use App\Models\DataQualityCheck;
use App\Models\Stock;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

class DataValidationService
{
    /**
     * Validate candles data for a stock and date range
     *
     * @param Collection<CandleDaily> $candles
     * @param Stock $stock
     * @param string $startDate
     * @param string $endDate
     * @return DataQualityResult
     */
    public function validate(Collection $candles, Stock $stock, string $startDate, string $endDate): DataQualityResult
    {
        $completenessScore = $this->calculateCompleteness($candles, $startDate, $endDate);
        $outlierScore = $this->calculateOutlierScore($candles);
        $qualityScore = ($completenessScore + $outlierScore) / 2;

        $validationErrors = [];

        if ($completenessScore < 80) {
            $validationErrors[] = 'بيانات غير مكتملة - توجد أيام مفقودة';
        }

        if ($outlierScore < 70) {
            $validationErrors[] = 'بيانات تحتوي على قيم شاذة - قد تحتاج مراجعة';
        }

        $isAccepted = $qualityScore >= 70;

        // Log quality check
        DataQualityCheck::create([
            'stock_id' => $stock->id,
            'date' => $endDate,
            'quality_score' => (int) $qualityScore,
            'completeness_score' => (int) $completenessScore,
            'outlier_score' => (int) $outlierScore,
            'validation_errors' => $validationErrors,
            'is_accepted' => $isAccepted,
            'checked_at' => now(),
        ]);

        return new DataQualityResult($isAccepted, $qualityScore, $validationErrors);
    }

    /**
     * Calculate completeness score (0-100)
     */
    private function calculateCompleteness(Collection $candles, string $startDate, string $endDate): float
    {
        $expectedDays = \Carbon\Carbon::parse($startDate)->diffInDays(\Carbon\Carbon::parse($endDate)) + 1;
        $actualDays = $candles->count();

        if ($expectedDays === 0) {
            return 0;
        }

        return min(100, ($actualDays / $expectedDays) * 100);
    }

    /**
     * Calculate outlier score (0-100)
     */
    private function calculateOutlierScore(Collection $candles): float
    {
        if ($candles->isEmpty()) {
            return 0;
        }

        // Calculate price changes
        $priceChanges = $candles->map(function ($candle) {
            return abs($candle->close - $candle->open) / max($candle->open, 0.01);
        });

        $mean = $priceChanges->avg();
        $stdDev = $this->calculateStandardDeviation($priceChanges->toArray(), $mean);

        // Count outliers (beyond 3 standard deviations)
        $outlierCount = $priceChanges->filter(function ($change) use ($mean, $stdDev) {
            return abs($change - $mean) > 3 * $stdDev;
        })->count();

        $outlierRatio = $outlierCount / $candles->count();

        // Score: 100 if no outliers, decreases as outlier ratio increases
        return max(0, 100 - ($outlierRatio * 100));
    }

    /**
     * Calculate standard deviation
     */
    private function calculateStandardDeviation(array $values, float $mean): float
    {
        $variance = 0;
        $count = count($values);

        if ($count === 0) {
            return 0;
        }

        foreach ($values as $value) {
            $variance += pow($value - $mean, 2);
        }

        return sqrt($variance / $count);
    }
}

class DataQualityResult
{
    public function __construct(
        public bool $canPublish,
        public float $score,
        public array $errors,
    ) {
    }
}
