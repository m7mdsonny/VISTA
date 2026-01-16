<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;

class AlertsController extends Controller
{
    public function index(Request $request)
    {
        $alerts = Alert::where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json($alerts->map(fn (Alert $alert) => [
            'id' => (string) $alert->id,
            'type' => $alert->type,
            'title' => $alert->payload_json['title'] ?? 'تنبيه',
            'message' => $alert->payload_json['message'] ?? '',
            'time' => $alert->payload_json['time'] ?? 'الآن',
            'isRead' => $alert->is_read,
        ]));
    }

    public function markRead(Request $request, string $id)
    {
        $alert = Alert::where('user_id', $request->user()->id)->findOrFail($id);
        $alert->update(['is_read' => true]);

        return response()->json([
            'id' => (string) $alert->id,
            'isRead' => true,
        ]);
    }
}
