<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('candles_daily', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->decimal('open', 12, 2);
            $table->decimal('high', 12, 2);
            $table->decimal('low', 12, 2);
            $table->decimal('close', 12, 2);
            $table->bigInteger('volume');
            $table->timestamps();
            $table->unique(['stock_id', 'date']);
        });

        Schema::create('indicators_daily', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->decimal('rsi', 6, 2)->nullable();
            $table->decimal('ma20', 12, 2)->nullable();
            $table->decimal('ma50', 12, 2)->nullable();
            $table->decimal('ma200', 12, 2)->nullable();
            $table->decimal('vol20', 12, 4)->nullable();
            $table->decimal('vol60', 12, 4)->nullable();
            $table->decimal('avg_volume20', 14, 2)->nullable();
            $table->decimal('avg_volume60', 14, 2)->nullable();
            $table->timestamps();
            $table->unique(['stock_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('indicators_daily');
        Schema::dropIfExists('candles_daily');
    }
};
