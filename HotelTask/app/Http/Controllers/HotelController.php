<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Hotel;
use App\Models\Room;

class HotelController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'search' => 'nullable|string|max:255',
        ]);
        
        $search = trim($request->input('search', ''));

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

        $filters = [
            'location' => $location,
            'price' => $price,
        ];

        $hotels = Hotel::with('rooms')
                    ->filter($filters)
                    ->get();

        return view('hotels.index', compact('hotels'));
    }

    public function show(Request $request, string $id)
    {
        $request->validate([
            'min_price' => 'nullable|numeric|min:0',
            'max_price' => 'nullable|numeric|min:0',
        ]);

        $hotel = Hotel::findOrFail($id);

        $rooms = $hotel->rooms()
                ->priceRange($request->input('min_price'), $request->input('max_price'))
                ->orderBy('price')
                ->paginate(5);

        return view('hotels.detailsHome', compact('hotel', 'rooms'));
    }
}
