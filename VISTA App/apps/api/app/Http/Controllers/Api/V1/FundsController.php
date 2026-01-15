<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Fund;

class FundsController extends Controller
{
    public function index()
    {
        $funds = Fund::where('is_active', true)->get();

        return response()->json($funds->map(fn (Fund $fund) => [
            'id' => (string) $fund->id,
            'name' => $fund->name_ar,
            'nav' => $fund->metadata['nav'] ?? 0,
            'change' => $fund->metadata['change'] ?? 0,
            'type' => $fund->type_ar,
        ]));
    }

    public function show(string $id)
    {
        $fund = Fund::findOrFail($id);

        return response()->json([
            'id' => (string) $fund->id,
            'name' => $fund->name_ar,
            'nav' => $fund->metadata['nav'] ?? 0,
            'change' => $fund->metadata['change'] ?? 0,
            'type' => $fund->type_ar,
        ]);
    }
}
