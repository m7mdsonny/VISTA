<?php

namespace App\Services;

use App\Models\DataQualityCheck;
use Illuminate\Support\Collection;

class DataQualityResult
{
    public function __construct(
        public bool $canPublish,
        public float $score,
        public array $anomalies,
    ) {
    }
}

class DataQualityService
{
    /**
     * @param array<int, array<string, mixed>> $dailyData
     */
    public function evaluate(array $dailyData): DataQualityResult
    {
        $count = count($dailyData);
        $missingClose = collect($dailyData)->whereNull('close')->count();
        $score = $count === 0 ? 0 : max(0, 100 - ($missingClose * 10));
        $anomalies = [];

        if ($missingClose > 0) {
            $anomalies[] = 'بيانات إغلاق ناقصة';
        }

        $result = new DataQualityResult($score >= 70, $score, $anomalies);

        DataQualityCheck::create([
            'date' => now()->toDateString(),
            'source' => 'seeded',
            'score' => $score,
            'anomalies_json' => $anomalies,
        ]);

        return $result;
    }
}
