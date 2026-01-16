<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Promotions table - العروض الترويجية
        Schema::create('promotions', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // 'SUMMER2024', 'NEWUSER50'
            $table->string('name_ar');
            $table->string('name_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->enum('type', ['percentage', 'fixed', 'free_trial'])->default('percentage');
            $table->decimal('discount_value', 10, 2)->default(0); // Percentage (0-100) or fixed amount
            $table->decimal('max_discount_amount', 10, 2)->nullable(); // Maximum discount cap
            $table->integer('free_trial_days')->nullable(); // For free_trial type
            $table->enum('applies_to', ['all', 'specific_plans'])->default('all');
            $table->json('applicable_plan_codes')->nullable(); // ['basic', 'pro'] if applies_to = specific_plans
            $table->enum('frequency', ['once', 'recurring'])->default('once'); // Once per user or recurring
            $table->integer('usage_limit')->nullable(); // Max times this promotion can be used (null = unlimited)
            $table->integer('usage_count')->default(0); // Current usage count
            $table->integer('per_user_limit')->default(1); // Max times per user
            $table->timestamp('starts_at');
            $table->timestamp('ends_at');
            $table->boolean('is_active')->default(true);
            $table->integer('minimum_plan_duration_months')->nullable(); // Minimum subscription duration
            $table->integer('priority')->default(0); // Higher priority = applied first
            $table->timestamps();
            
            $table->index(['code', 'is_active']);
            $table->index(['starts_at', 'ends_at']);
        });

        // User Promotions - Track which users used which promotions
        Schema::create('user_promotions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('promotion_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subscription_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('discount_applied', 10, 2)->default(0);
            $table->decimal('original_price', 10, 2);
            $table->decimal('final_price', 10, 2);
            $table->timestamp('used_at');
            $table->timestamps();
            
            $table->index(['user_id', 'promotion_id']);
            $table->index('subscription_id');
        });

        // API Providers - مزودي بيانات الأسهم
        Schema::create('api_providers', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique(); // 'egx_data', 'alpha_vantage', 'custom'
            $table->string('display_name_ar');
            $table->string('display_name_en')->nullable();
            $table->enum('type', ['egx_official', 'third_party', 'custom', 'scraper'])->default('third_party');
            $table->string('base_url');
            $table->string('api_key')->nullable(); // Encrypted
            $table->string('api_secret')->nullable(); // Encrypted
            $table->json('headers')->nullable(); // Custom headers
            $table->json('endpoints')->nullable(); // API endpoints config
            $table->enum('auth_type', ['none', 'api_key', 'bearer', 'basic', 'custom'])->default('api_key');
            $table->integer('rate_limit_per_minute')->default(60);
            $table->integer('rate_limit_per_day')->default(10000);
            $table->boolean('is_active')->default(true);
            $table->boolean('is_default')->default(false);
            $table->integer('timeout_seconds')->default(30);
            $table->integer('retry_attempts')->default(3);
            $table->text('notes')->nullable();
            $table->timestamps();
            
            $table->index('is_active');
            $table->index('is_default');
        });

        // API Provider Logs - تتبع استخدام API providers
        Schema::create('api_provider_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('provider_id')->constrained('api_providers')->cascadeOnDelete();
            $table->string('endpoint');
            $table->enum('status', ['success', 'failed', 'rate_limited', 'timeout'])->default('success');
            $table->integer('response_time_ms')->nullable();
            $table->integer('http_status_code')->nullable();
            $table->text('error_message')->nullable();
            $table->json('request_data')->nullable();
            $table->json('response_data')->nullable();
            $table->timestamp('requested_at');
            $table->timestamps();
            
            $table->index(['provider_id', 'status']);
            $table->index('requested_at');
        });

        // Update subscriptions table to add promotion support
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->foreignId('promotion_id')->nullable()->after('plan_id')->constrained()->nullOnDelete();
            $table->decimal('original_price', 10, 2)->nullable()->after('promotion_id');
            $table->decimal('discount_amount', 10, 2)->nullable()->after('original_price');
            $table->decimal('final_price', 10, 2)->nullable()->after('discount_amount');
            $table->index('promotion_id');
        });
    }

    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropForeign(['promotion_id']);
            $table->dropColumn(['promotion_id', 'original_price', 'discount_amount', 'final_price']);
        });

        Schema::dropIfExists('api_provider_logs');
        Schema::dropIfExists('api_providers');
        Schema::dropIfExists('user_promotions');
        Schema::dropIfExists('promotions');
    }
};
