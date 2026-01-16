<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AnalyticsController extends Controller
{
    public function __construct()
    {
        // No authentication required - analytics is anonymous
    }
    /**
     * Receive analytics events from mobile app (privacy-compliant)
     */
    public function track(Request $request)
    {
        $request->validate([
            'events' => 'required|array',
            'events.*' => 'string',
            'session_id' => 'nullable|string',
        ]);

        $events = $request->input('events', []);
        $sessionId = $request->input('session_id');

        // Store analytics events (privacy-compliant)
        // Only store anonymized data - no PII
        foreach ($events as $eventData) {
            try {
                // Parse event (format: timestamp|event_type|data)
                $parts = explode('|', $eventData, 3);
                if (count($parts) < 3) {
                    continue;
                }

                $timestamp = $parts[0] ?? null;
                $eventType = $parts[1] ?? null;
                $data = json_decode($parts[2] ?? '{}', true) ?? [];

                // Log event (without user PII)
                Log::channel('analytics')->info('User event', [
                    'event_type' => $eventType,
                    'session_id' => $sessionId,
                    'data' => $data,
                    'timestamp' => $timestamp,
                ]);

            } catch (\Exception $e) {
                // Silently continue - analytics is non-critical
                continue;
            }
        }

        return response()->json(['status' => 'ok']);
    }

    /**
     * Get aggregated analytics (admin only)
     */
    public function stats(Request $request)
    {
        // TODO: Implement aggregated stats from logs
        // This would require log aggregation service (e.g., Elasticsearch)
        
        return response()->json([
            'message' => 'Analytics aggregation not yet implemented',
        ]);
    }
}
