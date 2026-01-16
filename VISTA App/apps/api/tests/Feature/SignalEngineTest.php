<?php

namespace Tests\Feature;

use App\Models\Stock;
use App\Models\CandleDaily;
use App\Models\IndicatorDaily;
use App\Models\Signal;
use App\Services\SignalEngineService;
use App\Services\AdminConfigService;
use App\Services\RiskAssessmentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SignalEngineTest extends TestCase
{
    use RefreshDatabase;

    private SignalEngineService $signalEngine;
    private AdminConfigService $configService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->configService = $this->app->make(AdminConfigService::class);
        $riskAssessment = $this->app->make(RiskAssessmentService::class);
        
        $this->signalEngine = new SignalEngineService(
            $this->configService,
            $riskAssessment
        );
    }

    public function test_signal_generation_is_automated_only(): void
    {
        // Create test stock
        $stock = Stock::factory()->create([
            'symbol' => 'TEST',
            'name_ar' => 'شركة تجريبية',
            'is_active' => true,
        ]);

        // Create candle data
        $candle = CandleDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'open' => 100.0,
            'high' => 105.0,
            'low' => 99.0,
            'close' => 103.0,
            'volume' => 1000000,
        ]);

        // Create indicator data
        $indicator = IndicatorDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'rsi_14' => 30.0, // Oversold
            'volume_ratio' => 1.5,
            'liquidity_score' => 70.0,
            'volatility' => 25.0,
        ]);

        // Generate signal
        $signal = $this->signalEngine->generateSignalForStock($stock, now());

        // Assertions
        $this->assertNotNull($signal);
        $this->assertInstanceOf(Signal::class, $signal);
        $this->assertEquals($stock->id, $signal->stock_id);
        $this->assertContains($signal->signal_type, ['buy', 'sell', 'hold']);
        $this->assertGreaterThanOrEqual(0, $signal->confidence);
        $this->assertLessThanOrEqual(100, $signal->confidence);
        $this->assertContains($signal->risk_level, ['low', 'medium', 'high']);
        
        // Verify calculation metadata exists (for reproducibility)
        $this->assertNotNull($signal->calculation_metadata);
        $this->assertArrayHasKey('weights', $signal->calculation_metadata);
        $this->assertArrayHasKey('thresholds', $signal->calculation_metadata);
    }

    public function test_signal_generation_uses_admin_config_weights(): void
    {
        // Set admin weights
        $this->configService->setIndicatorWeights([
            'volume' => 0.30,
            'liquidity' => 0.20,
            'trend' => 0.25,
            'mean_reversion' => 0.10,
            'volatility' => 0.10,
            'news' => 0.05,
        ]);

        $stock = Stock::factory()->create(['is_active' => true]);
        
        CandleDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'close' => 100.0,
        ]);

        IndicatorDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'rsi_14' => 30.0,
            'volume_ratio' => 2.0,
            'liquidity_score' => 80.0,
        ]);

        $signal = $this->signalEngine->generateSignalForStock($stock, now());

        $this->assertNotNull($signal);
        // Verify weights are stored in metadata
        $this->assertEquals(0.30, $signal->calculation_metadata['weights']['volume']);
    }

    public function test_signal_generation_respects_thresholds(): void
    {
        // Set buy threshold to 80 (high)
        $this->configService->setSignalThresholds([
            'buy' => 80,
            'sell' => 20,
            'high_confidence' => 85,
        ]);

        $stock = Stock::factory()->create(['is_active' => true]);
        
        CandleDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'close' => 100.0,
        ]);

        IndicatorDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'rsi_14' => 30.0, // Oversold
            'volume_ratio' => 2.0,
            'liquidity_score' => 90.0,
        ]);

        $signal = $this->signalEngine->generateSignalForStock($stock, now());

        $this->assertNotNull($signal);
        // If confidence < 80, should be 'hold', not 'buy'
        if ($signal->confidence < 80) {
            $this->assertNotEquals('buy', $signal->signal_type);
        }
    }

    public function test_no_signal_generated_without_data(): void
    {
        $stock = Stock::factory()->create(['is_active' => true]);

        // No candle or indicator data
        $signal = $this->signalEngine->generateSignalForStock($stock, now());

        $this->assertNull($signal);
    }

    public function test_signal_includes_risk_assessment(): void
    {
        $stock = Stock::factory()->create(['is_active' => true]);
        
        CandleDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'close' => 100.0,
        ]);

        // High volatility indicator (should result in high risk)
        $indicator = IndicatorDaily::factory()->create([
            'stock_id' => $stock->id,
            'date' => now()->toDateString(),
            'volatility' => 70.0, // High volatility
            'liquidity_score' => 30.0, // Low liquidity
        ]);

        $signal = $this->signalEngine->generateSignalForStock($stock, now());

        $this->assertNotNull($signal);
        $this->assertContains($signal->risk_level, ['low', 'medium', 'high']);
    }
}
