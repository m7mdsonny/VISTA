<?php

namespace App\Services;

use App\Models\NotificationEvent;
use Illuminate\Support\Collection;

class NotificationRulesService
{
    public function createEventsForSignals(Collection $signals, int $hoursWindow = 6): void
    {
        $settings = \App\Models\AdminSetting::where('key', 'notification_rules')->value('value_json');
        $hoursWindow = $settings['repeat_window_hours'] ?? $hoursWindow;

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
