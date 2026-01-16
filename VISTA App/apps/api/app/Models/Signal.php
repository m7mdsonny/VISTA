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
        'type', // Database column name (matches migration)
        'confidence',
        'risk_level',
        'price_at_signal',
        'target_price',
        'stop_loss',
        'calculation_metadata',
        'status',
        'source_version',
    ];

    protected $casts = [
        'date' => 'date',
        'confidence' => 'integer',
        'price_at_signal' => 'decimal:4',
        'target_price' => 'decimal:4',
        'stop_loss' => 'decimal:4',
        'calculation_metadata' => 'array',
    ];

    /**
     * Accessor for signal_type (alias for type column)
     */
    public function getSignalTypeAttribute(): ?string
    {
        return $this->type;
    }

    /**
     * Mutator for signal_type (alias for type column)
     */
    public function setSignalTypeAttribute(string $value): void
    {
        $this->attributes['type'] = $value;
    }

    public function stock()
    {
        return $this->belongsTo(Stock::class);
    }

    public function explanation()
    {
        return $this->hasOne(SignalExplanation::class);
    }
}
