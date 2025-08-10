<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Builder;

class Hotel extends Model
{
    protected $fillable = ['name', 'location', 'description', 'rating', 'image'];
    
    public function rooms() {
        return $this->hasMany(Room::class);
    }

    public function scopeFilter(Builder $query, array $filters)
    {
        if (!empty($filters['location'])) {
            $location = strtolower(trim($filters['location']));
            $query->whereRaw('LOWER(SUBSTRING_INDEX(location, ",", -1)) LIKE ?', ["%{$location}%"]);
        }

        if (!empty($filters['price'])) {
            $query->whereHas('rooms', function ($q) use ($filters) {
                $q->where('price', '<=', $filters['price']);
            });
        }
        
        return $query;
    }
}
