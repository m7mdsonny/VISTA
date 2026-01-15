<?php

namespace Database\Factories;

use App\Models\Stock;
use Illuminate\Database\Eloquent\Factories\Factory;

class StockFactory extends Factory
{
    protected $model = Stock::class;

    public function definition(): array
    {
        return [
            'ticker' => $this->faker->unique()->lexify('???'),
            'name_ar' => 'سهم تجريبي',
            'sector_ar' => 'قطاع تجريبي',
            'is_active' => true,
            'metadata' => [],
        ];
    }
}
