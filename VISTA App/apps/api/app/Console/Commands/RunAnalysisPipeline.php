<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\MarketData\SeededProvider;
use App\Services\IndicatorService;
use App\Services\SignalEngineService;
use App\Services\ExplainabilityService;
use App\Services\DataQualityService;
use App\Services\NotificationRulesService;

class RunAnalysisPipeline extends Command
{
    protected $signature = 'vista:analysis-run';
    protected $description = 'تشغيل خط تحليل السوق اليومي وإنتاج الإشارات';

    public function handle(
        SeededProvider $provider,
        IndicatorService $indicatorService,
        SignalEngineService $signalEngine,
        ExplainabilityService $explainability,
        DataQualityService $dataQuality,
        NotificationRulesService $notificationRules
    ): int {
        $this->info('بدء تشغيل خط التحليل...');

        $dailyData = $provider->fetchDailyCandles();
        $quality = $dataQuality->evaluate($dailyData);

        if (! $quality->canPublish) {
            $this->warn('جودة البيانات غير كافية. تم إيقاف نشر الإشارات.');
            return self::SUCCESS;
        }

        $indicators = $indicatorService->compute($dailyData);
        $signals = $signalEngine->generate($dailyData, $indicators);
        $explanations = $explainability->attach($signals, $indicators);
        $notificationRules->createEventsForSignals($signals);

        $this->info("تم إنشاء {$signals->count()} إشارة وتخزينها بنجاح.");

        return self::SUCCESS;
    }
}
