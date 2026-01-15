<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class WebhookController extends Controller
{
    public function apple(Request $request)
    {
        if (! $this->hasValidSignature($request)) {
            return response()->json(['message' => 'التوقيع غير صالح'], 401);
        }

        return response()->json(['message' => 'تم استلام إشعار Apple بنجاح']);
    }

    public function google(Request $request)
    {
        if (! $this->hasValidSignature($request)) {
            return response()->json(['message' => 'التوقيع غير صالح'], 401);
        }

        return response()->json(['message' => 'تم استلام إشعار Google بنجاح']);
    }

    private function hasValidSignature(Request $request): bool
    {
        $signature = $request->header('X-Signature');
        return ! empty($signature);
    }
}
