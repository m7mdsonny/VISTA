<?php

namespace App\Services;

use App\Models\ApiProvider;
use App\Models\ApiProviderLog;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class MarketDataProviderService
{
    private ?ApiProvider $currentProvider = null;

    /**
     * Get active API provider
     */
    public function getActiveProvider(): ?ApiProvider
    {
        if ($this->currentProvider) {
            return $this->currentProvider;
        }

        // Get default provider or first active
        $this->currentProvider = ApiProvider::where('is_active', true)
            ->where('is_default', true)
            ->first() ?? ApiProvider::where('is_active', true)->first();

        return $this->currentProvider;
    }

    /**
     * Set provider by name
     */
    public function setProvider(string $providerName): bool
    {
        $provider = ApiProvider::where('name', $providerName)
            ->where('is_active', true)
            ->first();

        if (!$provider) {
            return false;
        }

        $this->currentProvider = $provider;
        return true;
    }

    /**
     * Fetch daily candles from API provider
     */
    public function fetchDailyCandles(string $symbol, ?\Carbon\Carbon $date = null): ?array
    {
        $provider = $this->getActiveProvider();

        if (!$provider) {
            Log::error('No active API provider configured');
            return null;
        }

        // Check rate limit
        if (!$this->checkRateLimit($provider)) {
            Log::warning('API provider rate limit exceeded', ['provider' => $provider->name]);
            return null;
        }

        $startTime = microtime(true);

        try {
            // Build request
            $url = $this->buildUrl($provider, 'daily_candles', [
                'symbol' => $symbol,
                'date' => $date ? $date->toDateString() : now()->toDateString(),
            ]);

            $headers = $this->buildHeaders($provider);

            // Make request
            $response = Http::timeout($provider->timeout_seconds)
                ->withHeaders($headers)
                ->get($url);

            $responseTime = (int) ((microtime(true) - $startTime) * 1000);

            // Log request
            $this->logRequest($provider, 'daily_candles', $response, $responseTime);

            if ($response->successful()) {
                $data = $response->json();
                return $this->normalizeCandleData($data, $provider);
            }

            return null;

        } catch (\Exception $e) {
            $responseTime = (int) ((microtime(true) - $startTime) * 1000);
            $this->logRequest($provider, 'daily_candles', null, $responseTime, 'failed', $e->getMessage());
            return null;
        }
    }

    /**
     * Fetch all stocks data
     */
    public function fetchAllStocks(): ?array
    {
        $provider = $this->getActiveProvider();

        if (!$provider) {
            return null;
        }

        if (!$this->checkRateLimit($provider)) {
            return null;
        }

        $startTime = microtime(true);

        try {
            $url = $this->buildUrl($provider, 'all_stocks');
            $headers = $this->buildHeaders($provider);

            $response = Http::timeout($provider->timeout_seconds)
                ->withHeaders($headers)
                ->get($url);

            $responseTime = (int) ((microtime(true) - $startTime) * 1000);
            $this->logRequest($provider, 'all_stocks', $response, $responseTime);

            if ($response->successful()) {
                return $this->normalizeStocksData($response->json(), $provider);
            }

            return null;

        } catch (\Exception $e) {
            $responseTime = (int) ((microtime(true) - $startTime) * 1000);
            $this->logRequest($provider, 'all_stocks', null, $responseTime, 'failed', $e->getMessage());
            return null;
        }
    }

    /**
     * Build API URL with endpoint
     */
    private function buildUrl(ApiProvider $provider, string $endpointKey, array $params = []): string
    {
        $endpoints = $provider->endpoints ?? [];
        $endpointTemplate = $endpoints[$endpointKey] ?? '/api/stocks/{symbol}';

        // Replace placeholders
        foreach ($params as $key => $value) {
            $endpointTemplate = str_replace('{' . $key . '}', $value, $endpointTemplate);
        }

        return rtrim($provider->base_url, '/') . '/' . ltrim($endpointTemplate, '/');
    }

    /**
     * Build request headers
     */
    private function buildHeaders(ApiProvider $provider): array
    {
        $headers = $provider->headers ?? [];

        // Add authentication headers based on auth_type
        switch ($provider->auth_type) {
            case 'api_key':
                if ($provider->api_key) {
                    $headers['X-API-Key'] = $provider->api_key;
                    // Or in query parameter (depends on provider)
                }
                break;

            case 'bearer':
                if ($provider->api_key) {
                    $headers['Authorization'] = 'Bearer ' . $provider->api_key;
                }
                break;

            case 'basic':
                if ($provider->api_key && $provider->api_secret) {
                    $credentials = base64_encode($provider->api_key . ':' . $provider->api_secret);
                    $headers['Authorization'] = 'Basic ' . $credentials;
                }
                break;
        }

        return $headers;
    }

    /**
     * Check rate limit
     */
    private function checkRateLimit(ApiProvider $provider): bool
    {
        $cacheKey = "api_provider_rate_limit:{$provider->id}:" . now()->format('Y-m-d-H-i');
        $minuteKey = "api_provider_rate_limit:{$provider->id}:" . now()->format('Y-m-d-H-i');
        $dayKey = "api_provider_rate_limit:{$provider->id}:" . now()->format('Y-m-d');

        // Check minute limit
        $minuteCount = Cache::get($minuteKey, 0);
        if ($minuteCount >= $provider->rate_limit_per_minute) {
            return false;
        }

        // Check day limit
        $dayCount = Cache::get($dayKey, 0);
        if ($dayCount >= $provider->rate_limit_per_day) {
            return false;
        }

        // Increment counters
        Cache::put($minuteKey, $minuteCount + 1, now()->addMinute());
        Cache::put($dayKey, $dayCount + 1, now()->endOfDay());

        return true;
    }

    /**
     * Normalize candle data from provider response
     */
    private function normalizeCandleData(array $data, ApiProvider $provider): array
    {
        // Normalize based on provider type
        // This should be customized based on actual API response format
        return [
            'symbol' => $data['symbol'] ?? $data['ticker'] ?? null,
            'date' => $data['date'] ?? $data['timestamp'] ?? now()->toDateString(),
            'open' => (float) ($data['open'] ?? $data['o'] ?? 0),
            'high' => (float) ($data['high'] ?? $data['h'] ?? 0),
            'low' => (float) ($data['low'] ?? $data['l'] ?? 0),
            'close' => (float) ($data['close'] ?? $data['c'] ?? 0),
            'volume' => (int) ($data['volume'] ?? $data['v'] ?? 0),
        ];
    }

    /**
     * Normalize stocks data
     */
    private function normalizeStocksData(array $data, ApiProvider $provider): array
    {
        // Normalize array of stocks
        $stocks = $data['data'] ?? $data['stocks'] ?? $data;

        return array_map(function ($stock) {
            return [
                'symbol' => $stock['symbol'] ?? $stock['ticker'] ?? null,
                'name_ar' => $stock['name_ar'] ?? $stock['name'] ?? null,
                'price' => (float) ($stock['price'] ?? $stock['close'] ?? 0),
                'change' => (float) ($stock['change'] ?? 0),
                'change_percent' => (float) ($stock['change_percent'] ?? 0),
                'volume' => (int) ($stock['volume'] ?? 0),
                'sector' => $stock['sector'] ?? null,
            ];
        }, is_array($stocks) && isset($stocks[0]) ? $stocks : [$stocks]);
    }

    /**
     * Log API request
     */
    private function logRequest(
        ApiProvider $provider,
        string $endpoint,
        $response,
        int $responseTime,
        string $status = 'success',
        ?string $errorMessage = null
    ): void {
        ApiProviderLog::create([
            'provider_id' => $provider->id,
            'endpoint' => $endpoint,
            'status' => $status,
            'response_time_ms' => $responseTime,
            'http_status_code' => $response?->status(),
            'error_message' => $errorMessage,
            'response_data' => $response ? ['status' => $response->status()] : null,
            'requested_at' => now(),
        ]);
    }
}
