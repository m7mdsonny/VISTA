<?php

namespace Database\Seeders;

use App\Models\ApiProvider;
use Illuminate\Database\Seeder;

class ApiProvidersSeeder extends Seeder
{
    public function run(): void
    {
        // Example: EGX Official Data Provider (placeholder)
        ApiProvider::create([
            'name' => 'egx_official',
            'display_name_ar' => 'البورصة المصرية - بيانات رسمية',
            'display_name_en' => 'Egyptian Exchange - Official Data',
            'type' => 'egx_official',
            'base_url' => 'https://api.egx.com.eg',
            'api_key' => null, // Will be set in admin panel
            'api_secret' => null,
            'auth_type' => 'none', // May require authentication
            'headers' => [
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            ],
            'endpoints' => [
                'daily_candles' => '/api/v1/stocks/{symbol}/candles?date={date}',
                'all_stocks' => '/api/v1/stocks',
                'funds' => '/api/v1/funds',
                'indices' => '/api/v1/indices',
            ],
            'rate_limit_per_minute' => 60,
            'rate_limit_per_day' => 10000,
            'timeout_seconds' => 30,
            'retry_attempts' => 3,
            'is_active' => false, // Not active until configured
            'is_default' => false,
            'notes' => 'يجب إضافة API Key من لوحة تحكم البورصة المصرية',
        ]);

        // Example: Third-party provider (Alpha Vantage style)
        ApiProvider::create([
            'name' => 'market_data_provider',
            'display_name_ar' => 'مزود بيانات السوق',
            'display_name_en' => 'Market Data Provider',
            'type' => 'third_party',
            'base_url' => 'https://api.marketdata.example.com',
            'api_key' => null, // Will be set in admin panel
            'api_secret' => null,
            'auth_type' => 'api_key',
            'headers' => [
                'Accept' => 'application/json',
                'X-API-Key' => '{api_key}', // Will be replaced
            ],
            'endpoints' => [
                'daily_candles' => '/v1/stocks/{symbol}/daily?date={date}',
                'all_stocks' => '/v1/stocks',
                'funds' => '/v1/funds',
            ],
            'rate_limit_per_minute' => 5, // Free tier limit
            'rate_limit_per_day' => 500,
            'timeout_seconds' => 30,
            'retry_attempts' => 3,
            'is_active' => false,
            'is_default' => false,
            'notes' => 'مثال على مزود بيانات خارجي - يجب تكوين API Key',
        ]);

        // Example: Custom/Scraper provider
        ApiProvider::create([
            'name' => 'scraper_provider',
            'display_name_ar' => 'مزود بيانات عبر Web Scraping',
            'display_name_en' => 'Web Scraping Provider',
            'type' => 'scraper',
            'base_url' => 'https://www.mubasher.info',
            'api_key' => null,
            'api_secret' => null,
            'auth_type' => 'none',
            'headers' => [
                'User-Agent' => 'Mozilla/5.0 (compatible; VistaBot/1.0)',
                'Accept' => 'text/html,application/xhtml+xml',
            ],
            'endpoints' => [
                'daily_candles' => '/markets/EGX/{symbol}',
                'all_stocks' => '/markets/EGX/stocks',
            ],
            'rate_limit_per_minute' => 10, // Be respectful
            'rate_limit_per_day' => 1000,
            'timeout_seconds' => 30,
            'retry_attempts' => 2,
            'is_active' => false,
            'is_default' => false,
            'notes' => 'مزود بيانات عبر Web Scraping - يجب مراعاة شروط الاستخدام',
        ]);
    }
}
