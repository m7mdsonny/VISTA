<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminConfigService;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AnalysisConfigController extends Controller
{
    public function __construct(
        private AdminConfigService $configService
    ) {
    }

    public function weights()
    {
        $weights = $this->configService->getIndicatorWeights();

        return view('admin.analysis.weights', compact('weights'));
    }

    public function updateWeights(Request $request)
    {
        $request->validate([
            'volume' => 'required|numeric|min:0|max:1',
            'liquidity' => 'required|numeric|min:0|max:1',
            'trend' => 'required|numeric|min:0|max:1',
            'mean_reversion' => 'required|numeric|min:0|max:1',
            'volatility' => 'required|numeric|min:0|max:1',
            'news' => 'required|numeric|min:0|max:1',
        ]);

        // Validate sum equals 1.0
        $sum = $request->volume + $request->liquidity + $request->trend 
            + $request->mean_reversion + $request->volatility + $request->news;

        if (abs($sum - 1.0) > 0.01) {
            return back()->withErrors(['weights' => 'يجب أن يكون مجموع الأوزان يساوي 1.0'])->withInput();
        }

        try {
            $this->configService->setIndicatorWeights([
                'volume' => $request->volume,
                'liquidity' => $request->liquidity,
                'trend' => $request->trend,
                'mean_reversion' => $request->mean_reversion,
                'volatility' => $request->volatility,
                'news' => $request->news,
            ], Auth::id());

            return back()->with('success', 'تم تحديث أوزان المؤشرات بنجاح');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => $e->getMessage()])->withInput();
        }
    }

    public function thresholds()
    {
        $thresholds = $this->configService->getSignalThresholds();

        return view('admin.analysis.thresholds', compact('thresholds'));
    }

    public function updateThresholds(Request $request)
    {
        $request->validate([
            'buy' => 'required|integer|min:0|max:100',
            'sell' => 'required|integer|min:0|max:100',
            'high_confidence' => 'required|integer|min:0|max:100',
        ]);

        try {
            $this->configService->setSignalThresholds([
                'buy' => $request->buy,
                'sell' => $request->sell,
                'high_confidence' => $request->high_confidence,
            ], Auth::id());

            return back()->with('success', 'تم تحديث حدود الإشارات بنجاح');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => $e->getMessage()])->withInput();
        }
    }

    public function risk()
    {
        $config = $this->configService->getRiskConfig();

        return view('admin.analysis.risk', compact('config'));
    }

    public function updateRisk(Request $request)
    {
        $request->validate([
            'volatility.low' => 'required|integer|min:0|max:100',
            'volatility.medium' => 'required|integer|min:0|max:100',
            'volatility.high' => 'required|integer|min:0|max:100',
            'liquidity.minimum' => 'required|integer|min:0|max:100',
        ]);

        $this->configService->set('risk.volatility.low', $request->input('volatility.low'), Auth::id());
        $this->configService->set('risk.volatility.medium', $request->input('volatility.medium'), Auth::id());
        $this->configService->set('risk.volatility.high', $request->input('volatility.high'), Auth::id());
        $this->configService->set('risk.liquidity.minimum', $request->input('liquidity.minimum'), Auth::id());

        return back()->with('success', 'تم تحديث إعدادات المخاطرة بنجاح');
    }

    public function liquidity()
    {
        $minAvgVolume = $this->configService->get('liquidity.min_avg_volume', 1000000);
        $minVolumeRatio = $this->configService->get('liquidity.min_volume_ratio', 0.5);
        $excludedStocks = $this->configService->get('liquidity.excluded_stocks', []);

        return view('admin.analysis.liquidity', compact('minAvgVolume', 'minVolumeRatio', 'excludedStocks'));
    }

    public function updateLiquidity(Request $request)
    {
        $request->validate([
            'min_avg_volume' => 'required|integer|min:0',
            'min_volume_ratio' => 'required|numeric|min:0|max:10',
            'excluded_stocks' => 'nullable|array',
            'excluded_stocks.*' => 'exists:stocks,id',
        ]);

        $this->configService->set('liquidity.min_avg_volume', $request->min_avg_volume, Auth::id());
        $this->configService->set('liquidity.min_volume_ratio', $request->min_volume_ratio, Auth::id());
        $this->configService->set('liquidity.excluded_stocks', $request->excluded_stocks ?? [], Auth::id());

        return back()->with('success', 'تم تحديث إعدادات السيولة بنجاح');
    }
}
