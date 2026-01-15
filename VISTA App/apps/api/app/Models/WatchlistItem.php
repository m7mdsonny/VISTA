<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WatchlistItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'watchlist_id',
        'stock_id',
        'fund_id',
        'type',
    ];

    public function watchlist()
    {
        return $this->belongsTo(Watchlist::class);
    }
}
