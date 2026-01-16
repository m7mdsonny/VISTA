<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\MarketDataIngestionService;
use App\Services\MarketDataProviderService;
use App\Services\IndicatorService;
use App\Services\SignalEngineService;
use App\Services\ExplainabilityService;
use App\Services\DataQualityService;
use App\Services\NotificationRulesService;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class RunAnalysisPipeline extends Command
{
    protected $signature = 'vista:analysis-run {--date=}';
    protected $description = 'تشغيل خط تحليل السوق اليومي وإنتاج الإشارات';

    public function handle(
        MarketDataProviderService $providerService,
        MarketDataIngestionService $ingestionService,
        IndicatorService $indicatorService,
        SignalEngineService $signalEngine,
        ExplainabilityService $explainability,
        DataQualityService $dataQuality,
        NotificationRulesService $notificationRules
    ): int {
        $this->info('🚀 بدء تشغيل خط التحليل الذكي...');

        try {
            // Get date to analyze (default: today)
            $date = $this->option('date')
                ? Carbon::parse($this->option('date'))
                : Carbon::today();

            $this->info("📅 تحليل بيانات التاريخ: {$date->toDateString()}");

            // Step 1: Fetch market data from API provider
            $this->info('📊 جلب بيانات السوق من مزود API...');
            $allStocks = $providerService->fetchAllStocks();

            if (empty($allStocks)) {
                $this->error('❌ فشل جلب بيانات السوق. تأكد من إعدادات مزود API.');
                return self::FAILURE;
            }

            $this->info("✅ تم جلب بيانات " . count($allStocks) . " سهم");

            // Step 2: Ingest data into database
            $this->info('💾 حفظ البيانات في قاعدة البيانات...');
            $dailyData = [];
            foreach ($allStocks as $stockData) {
                $candle = $ingestionService->ingestDailyCandle(
                    $stockData['symbol'],
                    $date,
                    $stockData
                );
                if ($candle) {
                    $dailyData[] = $candle;
                }
            }

            $this->info("✅ تم حفظ " . count($dailyData) . " شمعة يومية");

            // Step 3: Validate data quality
            $this->info('🔍 التحقق من جودة البيانات...');
            $qualityResult = $dataQuality->evaluate($dailyData);

            if (!$qualityResult->canPublish) {
                $this->warn("⚠️  تحذير: جودة البيانات غير كافية:");
                $this->warn("  - Score: {$qualityResult->score}");
                if (isset($qualityResult->anomalies) && !empty($qualityResult->anomalies)) {
                    foreach ($qualityResult->anomalies as $anomaly) {
                        $this->warn("  - {$anomaly}");
                    }
                }
                // Continue anyway but log warning
            }

            // Step 4: Compute technical indicators
            $this->info('📈 حساب المؤشرات الفنية...');
            $indicators = $indicatorService->compute($dailyData);

            $this->info("✅ تم حساب المؤشرات لـ " . $indicators->count() . " سهم");

            // Step 5: Generate signals using AI engine
            $this->info('🤖 توليد الإشارات باستخدام محرك الذكاء الاصطناعي...');
            $signals = $signalEngine->generateForDate($date);

            $this->info("✅ تم توليد " . $signals->count() . " إشارة");

            // Step 6: Attach explanations
            $this->info('📝 إضافة التفسيرات للإشارات...');
            $explanationsCount = 0;
            foreach ($signals as $signal) {
                $explanation = $explainability->attach($signal);
                if ($explanation) {
                    $explanationsCount++;
                }
            }

            $this->info("✅ تم إضافة تفسيرات لـ {$explanationsCount} إشارة");

            // Step 7: Create notification events
            $this->info('🔔 إنشاء أحداث الإشعارات...');
            $eventsCount = $notificationRules->createEventsForSignals($signals);

            $this->info("✅ تم إنشاء {$eventsCount} حدث إشعار");

            // Summary
            $this->newLine();
            $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            $this->info('✅ تم إكمال خط التحليل بنجاح!');
            $this->info("📊 الإحصائيات:");
            $this->info("  - الأسهم المعالجة: " . count($dailyData));
            $this->info("  - المؤشرات المحسوبة: " . $indicators->count());
            $this->info("  - الإشارات المولدة: " . $signals->count());
            $this->info("  - التفسيرات المضافة: {$explanationsCount}");
            $this->info("  - أحداث الإشعارات: {$eventsCount}");
            $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

            Log::info('Analysis pipeline completed successfully', [
                'date' => $date->toDateString(),
                'stocks_processed' => count($dailyData),
                'signals_generated' => $signals->count(),
            ]);

            return self::SUCCESS;

        } catch (\Exception $e) {
            $this->error("❌ خطأ في خط التحليل: " . $e->getMessage());
            $this->error("Stack trace: " . $e->getTraceAsString());

            Log::error('Analysis pipeline failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return self::FAILURE;
        }
    }
}
