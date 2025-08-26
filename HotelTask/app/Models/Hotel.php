<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\LogOptions;
use Spatie\Activitylog\Traits\LogsActivity;
use App\Exceptions\InvalidImageException;

class Hotel extends Model
{
    use SoftDeletes, LogsActivity;
    protected $fillable = ['name', 'location', 'description', 'rating', 'image'];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->useLogName('hotel')
            ->logFillable()
            ->logOnlyDirty();
    }

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

    public function uploadImage($file) {
        if ($file && $file->isValid()) {
            return $file->store('hotels', 'public');
        }
        throw new InvalidImageException();
    }

    public static function parseSearchInput(?string $search): array {
        $location = null;
        $price = null;
        if ($search !== '') {
            preg_match('/\d+(\.\d+)?/', $search, $priceMatch);

            if (!empty($priceMatch)) {
                $price = floatval($priceMatch[0]);
                $location = trim(str_replace($priceMatch[0], '', $search));
            } else {
                $location = $search;
            }
        }

        return [
            'location' => $location,
            'price' => $price,
        ];
    }
}
