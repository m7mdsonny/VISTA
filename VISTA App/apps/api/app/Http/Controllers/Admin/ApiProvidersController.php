<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ApiProvider;
use App\Models\ApiProviderLog;
use App\Services\AdminConfigService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;

class ApiProvidersController extends Controller
{
    public function __construct(
        private AdminConfigService $configService
    ) {
    }

    public function index()
    {
        $providers = ApiProvider::withCount('logs')->latest()->get();
        
        // Get statistics for each provider
        $stats = [];
        foreach ($providers as $provider) {
            $stats[$provider->id] = [
                'total_requests' => ApiProviderLog::where('provider_id', $provider->id)->count(),
                'success_rate' => $this->calculateSuccessRate($provider->id),
                'avg_response_time' => $this->calculateAvgResponseTime($provider->id),
                'requests_today' => ApiProviderLog::where('provider_id', $provider->id)
                    ->whereDate('requested_at', today())
                    ->count(),
            ];
        }

        return view('admin.api-providers.index', compact('providers', 'stats'));
    }

    public function create()
    {
        return view('admin.api-providers.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|unique:api_providers,name|max:100',
            'display_name_ar' => 'required|string|max:255',
            'display_name_en' => 'nullable|string|max:255',
            'type' => 'required|in:egx_official,third_party,custom,scraper',
            'base_url' => 'required|url|max:500',
            'api_key' => 'nullable|string|max:500',
            'api_secret' => 'nullable|string|max:500',
            'headers' => 'nullable|array',
            'endpoints' => 'required|array',
            'endpoints.daily_candles' => 'required|string',
            'endpoints.all_stocks' => 'required|string',
            'auth_type' => 'required|in:none,api_key,bearer,basic,custom',
            'rate_limit_per_minute' => 'required|integer|min:1|max:10000',
            'rate_limit_per_day' => 'required|integer|min:1|max:1000000',
            'timeout_seconds' => 'required|integer|min:1|max:300',
            'retry_attempts' => 'required|integer|min:0|max:10',
            'notes' => 'nullable|string',
            'is_active' => 'boolean',
            'is_default' => 'boolean',
        ]);

        // If this is set as default, unset others
        if ($request->has('is_default') && $request->is_default) {
            ApiProvider::where('is_default', true)->update(['is_default' => false]);
        }

        $provider = ApiProvider::create($validated);

        // Log admin action
        \App\Models\AuditLog::create([
            'user_id' => Auth::id(),
            'action' => 'api_provider.created',
            'resource_type' => 'ApiProvider',
            'resource_id' => $provider->id,
            'new_values' => array_merge($validated, ['api_key' => '***', 'api_secret' => '***']),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return redirect()->route('admin.api-providers.index')
            ->with('success', 'تم إضافة مزود API بنجاح');
    }

    public function edit($id)
    {
        $provider = ApiProvider::findOrFail($id);
        return view('admin.api-providers.edit', compact('provider'));
    }

    public function update(Request $request, $id)
    {
        $provider = ApiProvider::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:api_providers,name,' . $id,
            'display_name_ar' => 'required|string|max:255',
            'display_name_en' => 'nullable|string|max:255',
            'type' => 'required|in:egx_official,third_party,custom,scraper',
            'base_url' => 'required|url|max:500',
            'api_key' => 'nullable|string|max:500',
            'api_secret' => 'nullable|string|max:500',
            'headers' => 'nullable|array',
            'endpoints' => 'required|array',
            'auth_type' => 'required|in:none,api_key,bearer,basic,custom',
            'rate_limit_per_minute' => 'required|integer|min:1|max:10000',
            'rate_limit_per_day' => 'required|integer|min:1|max:1000000',
            'timeout_seconds' => 'required|integer|min:1|max:300',
            'retry_attempts' => 'required|integer|min:0|max:10',
            'notes' => 'nullable|string',
            'is_active' => 'boolean',
            'is_default' => 'boolean',
        ]);

        // Handle default provider
        if ($request->has('is_default') && $request->is_default && !$provider->is_default) {
            ApiProvider::where('is_default', true)->update(['is_default' => false]);
        }

        $oldValues = $provider->toArray();
        $provider->update($validated);

        // Log admin action
        \App\Models\AuditLog::create([
            'user_id' => Auth::id(),
            'action' => 'api_provider.updated',
            'resource_type' => 'ApiProvider',
            'resource_id' => $provider->id,
            'old_values' => array_merge($oldValues, ['api_key' => '***', 'api_secret' => '***']),
            'new_values' => array_merge($validated, ['api_key' => '***', 'api_secret' => '***']),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return redirect()->route('admin.api-providers.index')
            ->with('success', 'تم تحديث مزود API بنجاح');
    }

    public function test($id)
    {
        $provider = ApiProvider::findOrFail($id);

        try {
            $service = new \App\Services\MarketDataProviderService();
            $service->setProvider($provider->name);

            // Test with a known symbol
            $result = $service->fetchDailyCandles('COMI');

            if ($result) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'تم اختبار API بنجاح',
                    'data' => $result,
                ]);
            }

            return response()->json([
                'status' => 'failed',
                'message' => 'فشل الاتصال بـ API',
            ], 400);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function logs($id)
    {
        $provider = ApiProvider::findOrFail($id);
        $logs = ApiProviderLog::where('provider_id', $id)
            ->latest('requested_at')
            ->paginate(50);

        return view('admin.api-providers.logs', compact('provider', 'logs'));
    }

    private function calculateSuccessRate($providerId): float
    {
        $total = ApiProviderLog::where('provider_id', $providerId)->count();
        if ($total === 0) return 0;

        $successful = ApiProviderLog::where('provider_id', $providerId)
            ->where('status', 'success')
            ->count();

        return round(($successful / $total) * 100, 2);
    }

    private function calculateAvgResponseTime($providerId): float
    {
        return (float) ApiProviderLog::where('provider_id', $providerId)
            ->whereNotNull('response_time_ms')
            ->avg('response_time_ms') ?? 0;
    }
}
