<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NewsItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'title_ar',
        'summary_ar',
        'source',
        'published_at',
        'url',
    ];

    protected $casts = [
        'published_at' => 'datetime',
    ];
}
