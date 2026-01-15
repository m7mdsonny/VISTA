<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Signal extends Model
{
    use HasFactory;

    protected $fillable = [
        'stock_id',
        'date',
        'type',
        'confidence',
        'risk_level',
        'status',
        'source_version',
    ];

    protected $casts = [
        'date' => 'date',
        'confidence' => 'integer',
    ];

    public function stock()
    {
        return $this->belongsTo(Stock::class);
    }

    public function explanation()
    {
        return $this->hasOne(SignalExplanation::class);
    }
}
