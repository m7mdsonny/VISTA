<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class FeedbackController extends Controller
{
    /**
     * Submit user feedback
     */
    public function store(Request $request)
    {
        $request->validate([
            'rating' => 'nullable|integer|min:1|max:5',
            'category' => 'required|string|in:general,bug,feature,improvement',
            'message' => 'required|string|max:1000',
        ]);

        $user = $request->user();

        // Store feedback (could be in a feedback table, or just logs for now)
        Log::channel('feedback')->info('User feedback', [
            'user_id' => $user->id,
            'rating' => $request->input('rating'),
            'category' => $request->input('category'),
            'message' => $request->input('message'),
            'timestamp' => now()->toIso8601String(),
        ]);

        // Optional: Store in database table for better tracking
        // Feedback::create([...]);

        return response()->json([
            'message' => 'شكراً على ملاحظاتك!',
            'status' => 'success',
        ]);
    }
}
