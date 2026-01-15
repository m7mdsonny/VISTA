<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('signals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->string('type');
            $table->unsignedInteger('confidence');
            $table->string('risk_level');
            $table->string('status')->default('draft');
            $table->string('source_version')->nullable();
            $table->timestamps();
            $table->index(['stock_id', 'date']);
        });

        Schema::create('signal_explanations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('signal_id')->constrained()->cascadeOnDelete();
            $table->json('why_json');
            $table->json('caveats_json');
            $table->string('summary_ar');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('signal_explanations');
        Schema::dropIfExists('signals');
    }
};
