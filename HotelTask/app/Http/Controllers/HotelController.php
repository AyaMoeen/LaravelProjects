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
// use App\Services\HotelSearchService;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;
use App\Exceptions\InvalidImageException;
use App\Http\Requests\redisrequest;
use Carbon\Carbon;

class HotelController extends Controller
{
    use ApiResponse;

    public function index(searchRequest $request)
    {   
        $search = trim($request->input('search', ''));
        $filters = (new Hotel)->parseSearchInput($search); 
    
        $hotels = Hotel::with('rooms')
                    ->withCount('rooms')
                    ->filter($filters)
                    ->paginate(config('pagination.hotels_per_page')) 
                    ->withQueryString(); 

        return HotelResource::collection($hotels)
                    ->response()
                    ->setStatusCode(Response::HTTP_OK);  
    }
 
    public function show(RoomFilterRequest $request, string $id)
    {
        $hotel = Hotel::findOrFail($id);

        $rooms = $hotel->rooms()
                ->priceRange($request->input('min_price'), $request->input('max_price'))
                ->orderBy('price')
                ->paginate(config('pagination.rooms_per_page'));

        return [
            'hotel' => new HotelResource($hotel),
            'rooms' => RoomResource::collection($rooms),
        ];
    }

    public function destroy($id)
    {
        $hotel = Hotel::find($id);
    
        if (!$hotel) {
            return $this->errorResponse('Hotel not found', Response::HTTP_NOT_FOUND);
       }
   
        $hotel->delete();
        return $this->successResponse([], 'Hotel deleted successfully', Response::HTTP_OK);
    }


    public function bulkDestroy(BulkRequest $request) {
        
        $ids = $request->input('ids', []); 

        if (empty($ids)) {
            return $this->errorResponse([], 'No IDs provided', Response::HTTP_BAD_REQUEST); 
        }
        $hotels = Hotel::whereIn('id', $ids)->get();
        $foundIds = $hotels->pluck('id')->toArray();

        if (empty($foundIds)) {
            return $this->errorResponse([
                'deleted_ids'   => [],
                'not_found_ids' => $ids
            ], 'No hotels found for deletion', Response::HTTP_NOT_FOUND);
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
        ], 'Hotels deleted successfully', Response::HTTP_OK);
    }

public function store(StoreHotelRequest $request)
{
    $data = $request->validated();
    Log::info('Hotel store request validated', ['data' => $data]);
    try {
        
        $data['image'] = $request->file('image') 
        ? (new Hotel)->uploadImage($request->file('image')) 
        : null;

        $hotel = new Hotel;
        $hotel->fill($data);
        Log::info('About to save new hotel', ['hotel' => $hotel->toArray()]);
        $hotel->save();
        Log::info("Hotel created successfully", ['hotel_id' => $hotel->id]);


        $hotelId = $hotel->id;
        $date = now()->toDateString();
        

        $redisKey = "hotel:{$hotelId}:{$date}";

        Redis::set($redisKey, json_encode([
            'hotel_id'   => $hotelId,
            'name'       => $hotel->name,
            'image'      => $hotel->image,
            'date'       => $date,
        ]));

        return $this->successResponse($hotel,  __('messages.hotel_created'), Response::HTTP_CREATED);

    } catch (InvalidImageException $e) {
        Log::error('Image upload failed: ' . $e->getMessage(), [
            'exception' => $e,
            'trace'     => $e->getTraceAsString(),
        ]);

        return $this->errorResponse('Image upload failed: ' . $e->getMessage(), Response::HTTP_BAD_REQUEST);

    } catch (\Exception $e) {
        Log::error('Unexpected error in Hotel@store: ' . $e->getMessage(), [
            'exception' => $e,
            'trace'     => $e->getTraceAsString()
        ]);

        return $this->errorResponse('Something went wrong, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

public function getFromRedisByDate($startdate, $enddate)
{
    try {
        if ($startdate > $enddate) {
            return $this->errorResponse(
                'Start date must be before or equal to end date',
                Response::HTTP_UNPROCESSABLE_ENTITY 
            );
        }

        $prefix = config('database.redis.options.prefix') ?? '';

        $keys = Redis::keys("hotel:*");

        $hotels = [];
        foreach ($keys as $key) {
            $realKey = str_replace($prefix, '', $key);

            $data = json_decode(Redis::get($realKey), true);
            if (!$data) {
                continue;
            }

            $hotelDate = Carbon::parse($data['date']);
            $start = Carbon::parse($startdate);
            $end   = Carbon::parse($enddate);

            if ($hotelDate->between($start, $end)) {
                $hotels[] = $data;
            }
        }

        if (empty($hotels)) {
            return $this->errorResponse("No hotels found in Redis between {$startdate} and {$enddate}", Response::HTTP_NOT_FOUND);
        }
        return $this->successResponse($hotel, "Hotels between {$startdate} and {$enddate}", Response::HTTP_CREATED);

    } catch (\Exception $e) {
        Log::error('Error fetching hotels from Redis: ' . $e->getMessage(), [
            'exception' => $e,
            'trace' => $e->getTraceAsString()
        ]);

        return $this->errorResponse('Something went wrong, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}


public function storeInRedis(StoreHotelRequest $request)
{
    $data = $request->validated();
    try {
        
        $data['image'] = $request->file('image') 
        ? (new Hotel)->uploadImage($request->file('image')) 
        : null;

        $hotel = new Hotel;
        $hotel->fill($data);
        Log::info('About to save new hotel', ['hotel' => $hotel->toArray()]);
        $hotel->save();
        Log::info("Hotel created successfully", ['hotel_id' => $hotel->id]);


        $hotelId = $hotel->id;
        $startDate = $data['start_date'] ?? now()->toDateString();
        $endDate   = $data['end_date'] ?? now()->addDays(30)->toDateString();

        $redisKey = "hotel:{$hotelId}:{$startDate}:{$endDate}";

        Redis::set($redisKey, json_encode([
            'hotel_id'   => $hotelId,
            'name'       => $hotel->name,
            'image'      => $hotel->image,
            'start_date' => $startDate,
            'end_date'   => $endDate,
        ]));

        return $this->successResponse($hotel,  __('messages.hotel_created'), Response::HTTP_CREATED);

    } catch (InvalidImageException $e) {
        Log::error('Image upload failed: ' . $e->getMessage(), [
            'exception' => $e,
            'trace'     => $e->getTraceAsString(),
        ]);

        return $this->errorResponse('Image upload failed: ' . $e->getMessage(), Response::HTTP_BAD_REQUEST);

    } catch (\Exception $e) {
        Log::error('Unexpected error in Hotel@store: ' . $e->getMessage(), [
            'exception' => $e,
            'trace'     => $e->getTraceAsString()
        ]);

        return $this->errorResponse('Something went wrong, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

public function getFromRedis($hotelId, $startDate, $endDate)
{
    $redisKey = "hotel:{$hotelId}:{$startDate}:{$endDate}";
    $hotelData = Redis::get($redisKey);

    if ($hotelData) {
        return $this->successResponse(
                json_decode($hotelData, true),
                __('Hotel retrieved from Redis'),
                Response::HTTP_OK
            );
    }

    return $this->errorResponse('Hotel not found in Redis', Response::HTTP_NOT_FOUND);
}
public function update(redisrequest $request, $hotelId, $start_date, $end_date)
{
    try {
        $data = $request->validated();
        
        $redisKey = "hotel:{$hotelId}:{$start_date}:{$end_date}";

        $hotelData = Redis::get($redisKey);

        if (!$hotelData) {
            return $this->errorResponse('Hotel not found in Redis', Response::HTTP_NOT_FOUND);
        }

        $hotelData = json_decode($hotelData, true);

        $updatedData = array_merge($hotelData, $data);

        Redis::set($redisKey, json_encode($updatedData));

        return $this->successResponse($updatedData, 'Hotel updated in Redis successfully', Response::HTTP_OK);

    } catch (\Exception $e) {
        Log::error('Error updating hotel in Redis: ' . $e->getMessage());
        return $this->errorResponse('Something went wrong, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

public function deleteFromRedis($hotelId, $startDate, $endDate)
{
    try {
        $redisKey = "hotel:{$hotelId}:{$startDate}:{$endDate}";

        if (!Redis::exists($redisKey)) {
            return $this->errorResponse('Hotel not found in Redis', Response::HTTP_NOT_FOUND);
        }

        Redis::del($redisKey);

        return $this->successResponse(
            null,
            'Hotel deleted from Redis successfully',
            Response::HTTP_OK
        );
    } catch (\Exception $e) {
        Log::error('Error deleting hotel from Redis: ' . $e->getMessage());
        return $this->errorResponse('Something went wrong, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}


}
