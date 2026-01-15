<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SignalExplanation extends Model
{
    use HasFactory;

    protected $fillable = [
        'signal_id',
        'why_json',
        'caveats_json',
        'summary_ar',
    ];

    protected $casts = [
        'why_json' => 'array',
        'caveats_json' => 'array',
    ];

    public function signal()
    {
        return $this->belongsTo(Signal::class);
    }
}
