<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('data_quality_checks', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->string('source');
            $table->unsignedInteger('score');
            $table->json('anomalies_json')->nullable();
            $table->timestamps();
        });

        Schema::create('news_items', function (Blueprint $table) {
            $table->id();
            $table->string('title_ar');
            $table->text('summary_ar')->nullable();
            $table->string('source')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->string('url')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('news_items');
        Schema::dropIfExists('data_quality_checks');
    }
};
