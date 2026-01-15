<?php

namespace App\Services;

use App\Models\NotificationEvent;
use Illuminate\Support\Collection;

class NotificationRulesService
{
    public function createEventsForSignals(Collection $signals, int $hoursWindow = 6): void
    {
        foreach ($signals as $signal) {
            $exists = NotificationEvent::query()
                ->where('type', 'signal')
                ->where('payload_json->stock_id', $signal->stock_id)
                ->where('created_at', '>=', now()->subHours($hoursWindow))
                ->exists();

            if ($exists) {
                continue;
            }

            NotificationEvent::create([
                'user_id' => null,
                'type' => 'signal',
                'payload_json' => [
                    'stock_id' => $signal->stock_id,
                    'signal_id' => $signal->id,
                ],
                'status' => 'pending',
            ]);
        }
    }
}
