<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'password' => Hash::make($request->input('password')),
        ]);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => (string) $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ]);
    }

    public function login(LoginRequest $request)
    {
        $user = User::where('email', $request->input('email'))->first();

        if (! $user || ! Hash::check($request->input('password'), $user->password)) {
            return response()->json(['message' => 'بيانات الدخول غير صحيحة'], 422);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => (string) $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'id' => (string) $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج بنجاح',
        ]);
    }

    public function registerDevice(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
            'platform' => 'required|string|in:ios,android',
            'device_id' => 'nullable|string',
            'app_version' => 'nullable|string',
        ]);

        $user = $request->user();

        $device = \App\Models\Device::updateOrCreate(
            [
                'user_id' => $user->id,
                'platform' => $request->input('platform'),
                'device_id' => $request->input('device_id'),
            ],
            [
                'fcm_token' => $request->input('fcm_token'),
                'app_version' => $request->input('app_version'),
                'last_active_at' => now(),
            ]
        );

        return response()->json([
            'id' => $device->id,
            'platform' => $device->platform,
            'fcm_token' => $device->fcm_token,
            'device_id' => $device->device_id,
        ], 201);
    }
}
