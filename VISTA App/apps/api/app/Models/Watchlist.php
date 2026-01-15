<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Watchlist extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name_ar',
    ];

    public function items()
    {
        return $this->hasMany(WatchlistItem::class);
    }
}
