<?php

namespace App\Services;

class HotelSearchService
{
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