<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    protected $fillable = ['hotel_id', 'name', 'price', 'capacity'];

    public function hotel() {
        return $this->belongsTo(Hotel::class);
    }

    public function bookings() {
        return $this->hasMany(Booking::class);
    }

    public function scopePriceRange($query, $min, $max) {
        if($min != null) {
            $query->where('price', '>=', $min);
        }
        if($max != null) {
            $query->where('price', '<=', $max);
        }

        return $query;
    }
}
