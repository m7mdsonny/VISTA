<?php

namespace Database\Factories;

use App\Models\Signal;
use App\Models\Stock;
use Illuminate\Database\Eloquent\Factories\Factory;

class SignalFactory extends Factory
{
    protected $model = Signal::class;

    public function definition(): array
    {
        return [
            'stock_id' => Stock::factory(),
            'date' => now()->toDateString(),
            'type' => 'buy',
            'confidence' => 70,
            'risk_level' => 'medium',
            'status' => 'published',
            'source_version' => 'test',
        ];
    }
}
