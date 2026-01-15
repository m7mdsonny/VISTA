<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\WatchlistRequest;
use App\Http\Requests\WatchlistItemRequest;
use App\Models\Watchlist;
use App\Models\WatchlistItem;
use App\Models\Stock;
use App\Models\CandleDaily;
use Illuminate\Http\Request;

class WatchlistsController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $watchlists = Watchlist::with('items')->where('user_id', $user->id)->get();
        $favoritesList = $watchlists->firstWhere('name_ar', 'المفضلة');

        $favorites = $favoritesList
            ? $favoritesList->items->map(fn (WatchlistItem $item) => $this->mapStockItem($item->stock_id))
            : [];

        $lists = $watchlists->reject(fn (Watchlist $list) => $list->name_ar === 'المفضلة')
            ->map(fn (Watchlist $list) => [
                'id' => (string) $list->id,
                'name' => $list->name_ar,
                'stocks' => $list->items->map(fn (WatchlistItem $item) => $this->mapStockItem($item->stock_id, false)),
            ]);

        return response()->json([
            'favorites' => $favorites,
            'watchlists' => $lists,
        ]);
    }

    public function store(WatchlistRequest $request)
    {
        $watchlist = Watchlist::create([
            'user_id' => $request->user()->id,
            'name_ar' => $request->input('name'),
        ]);

        return response()->json([
            'id' => (string) $watchlist->id,
            'name' => $watchlist->name_ar,
            'stocks' => [],
        ]);
    }

    public function update(WatchlistRequest $request, string $id)
    {
        $watchlist = Watchlist::where('user_id', $request->user()->id)->findOrFail($id);
        $watchlist->update(['name_ar' => $request->input('name')]);

        return response()->json([
            'id' => (string) $watchlist->id,
            'name' => $watchlist->name_ar,
        ]);
    }

    public function destroy(Request $request, string $id)
    {
        $watchlist = Watchlist::where('user_id', $request->user()->id)->findOrFail($id);
        $watchlist->delete();

        return response()->json([
            'message' => 'تم حذف القائمة بنجاح',
        ]);
    }

    public function addItem(WatchlistItemRequest $request, string $id)
    {
        $watchlist = Watchlist::where('user_id', $request->user()->id)->findOrFail($id);
        $stock = Stock::where('ticker', $request->input('symbol'))->firstOrFail();

        $item = WatchlistItem::create([
            'watchlist_id' => $watchlist->id,
            'stock_id' => $stock->id,
            'type' => 'stock',
        ]);

        return response()->json([
            'id' => (string) $item->id,
            'symbol' => $stock->ticker,
        ]);
    }

    public function removeItem(Request $request, string $id, string $itemId)
    {
        $item = WatchlistItem::where('watchlist_id', $id)->findOrFail($itemId);
        $item->delete();

        return response()->json([
            'message' => 'تم حذف السهم من القائمة',
        ]);
    }

    private function mapStockItem(?int $stockId, bool $includeChart = true): array
    {
        $stock = Stock::find($stockId);
        $latest = CandleDaily::where('stock_id', $stockId)->orderByDesc('date')->first();
        $chart = $includeChart
            ? CandleDaily::where('stock_id', $stockId)->orderByDesc('date')->limit(5)->pluck('close')->reverse()->values()
            : null;

        $payload = [
            'symbol' => $stock?->ticker,
            'name' => $stock?->name_ar,
            'price' => $latest?->close ?? 0,
            'change' => $latest && $latest->open != 0
                ? round((($latest->close - $latest->open) / $latest->open) * 100, 2)
                : 0,
        ];

        if ($includeChart) {
            $payload['chart'] = $chart;
        }

        return $payload;
    }
}
