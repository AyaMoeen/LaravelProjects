<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Hotel;
use App\Models\Room;
use App\Http\Resources\HotelResource;
use App\Http\Resources\RoomResource;

class HotelController extends Controller
{
    public function index(Request $request)
    {   //note :: add validation request 
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
        // // return Hotel::with('rooms')
        // //             ->filter($filters)
        // //             ->get()
        // //             ->toResourceCollection();
        $hotels = Hotel::with('rooms')
                    ->withCount('rooms')
                    ->filter($filters)
                    ->paginate(3) 
                    ->withQueryString(); 

        return HotelResource::collection($hotels)
                    ->response()
                    ->setStatusCode(200);  
    }
    //note :: add validation request 
 
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

        return [
            'hotel' => new HotelResource($hotel),
            'rooms' => RoomResource::collection($rooms)->response()->getData(true),
        ];
    }

    public function destroy($id) {
        
        $hotel = Hotel::findOrFail($id);
        $hotel->delete();
        return response()->json(['message' => 'Hotel deleted successfully']);
    }

    //delete bulk record  multi id 
}
