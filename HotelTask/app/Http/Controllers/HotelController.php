<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Hotel;
use App\Models\Room;
use App\Http\Resources\HotelResource;
use App\Http\Resources\RoomResource;
use App\Http\Requests\RoomFilterRequest;
use App\Http\Requests\searchRequest;
use App\Http\Requests\BulkRequest;
use App\Http\Requests\StoreHotelRequest;
use App\Traits\ApiResponse;
use App\Services\HotelSearchService;

class HotelController extends Controller
{
    use ApiResponse;
    protected $hotelSearch;

    public function __construct(HotelSearchService $hotelSearch)
    {
        $this->hotelSearch = $hotelSearch;
    }

    public function index(searchRequest $request)
    {   
        $search = trim($request->input('search', ''));
        $filters = $this->hotelSearch->parseSearchInput($search);

        $hotels = Hotel::with('rooms')
                    ->withCount('rooms')
                    ->filter($filters)
                    ->paginate(3) 
                    ->withQueryString(); 

        return HotelResource::collection($hotels)
                    ->response()
                    ->setStatusCode(200);  
    }
 
    public function show(RoomFilterRequest $request, string $id)
    {
        $hotel = Hotel::findOrFail($id);

        $rooms = $hotel->rooms()
                ->priceRange($request->input('min_price'), $request->input('max_price'))
                ->orderBy('price')
                ->paginate(5);

        return [
            'hotel' => new HotelResource($hotel),
            'rooms' => RoomResource::collection($rooms),
        ];
    }

    public function destroy($id)
    {
        $hotel = Hotel::find($id);
    
        if (!$hotel) {
            return $this->errorResponse('Hotel not found', 404);
       }
   
        $hotel->delete();
        return $this->successResponse([], 'Hotel deleted successfully', 201);
    }


    public function bulkDestroy(BulkRequest $request) {
        
        $ids = $request->input('ids', []); 

        if (empty($ids)) {
            return $this->errorResponse([], 'No IDs provided', 400); 
        }
        $hotels = Hotel::whereIn('id', $ids)->get();
        $foundIds = $hotels->pluck('id')->toArray();

        if (empty($foundIds)) {
            return $this->errorResponse([
                'deleted_ids'   => [],
                'not_found_ids' => $ids
            ], 'No hotels found for deletion', 404);
        }
        
        Hotel::whereIn('id', $foundIds)->delete();

        activity()
            ->useLog('hotel')
            ->performedOn(new Hotel)
            ->withProperties(['deleted_ids' => $foundIds])
            ->tap(function ($activity) {
                $activity->event = 'bulk_deleted';
            })
            ->log('Bulk deleted hotels');

        return $this->successResponse([
            'deleted_ids'   => $foundIds,
            'not_found_ids' => array_diff($ids, $foundIds),
        ], 'Hotels deleted successfully', 200);
    }

public function store(StoreHotelRequest $request)
{
    $data = $request->validated();
    try {
        
        $data['image'] = $request->file('image') 
        ? (new Hotel)->uploadImage($request->file('image')) 
        : null;

        $hotel = new Hotel;
        $hotel->fill($data);
        $hotel->save();

        return $this->successResponse($hotel, 'Hotel created successfully!', 201);

    } catch (InvalidImageException $e) {
        return $this->errorResponse([], $e->getMessage(), $e->getCode());
    } catch (\Exception $e) {
        return $this->errorResponse($e->getMessage(), 400);
    }
}

}
