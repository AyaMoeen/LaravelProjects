   <?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;
use App\Http\Middleware\SetLocale;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;

Route::get('/test-log', function () {
    Log::error('This is a test error log from /api/test-log');
    return response()->json(['status' => 'log written']);
});

Route::get('/redis-test', function () {
    Redis::set('name', 'AYA');
    return Redis::get('name'); 
});
Route::middleware([SetLocale::class])->group(function () {
   Route::get('/hotels', [HotelController::class, 'index']);
   Route::post('/hotels', [HotelController::class, 'store']);
   Route::get('/hotels/{id}',[HotelController::class, 'show']);
   Route::delete('/hotels/{id}', [HotelController::class, 'destroy']);
   Route::delete('/bulk', [HotelController::class, 'bulkDestroy']);
   Route::get('/hotelsredis/{hotelId}/{startdate}/{enddate}', [HotelController::class, 'getFromRedis']);
   Route::put('/hotelsupdate/{hotelId}/{start_date}/{end_date}', [HotelController::class, 'update']);
   Route::delete('hotelsdelete/{hotelId}/{startDate}/{endDate}', [HotelController::class, 'deleteFromRedis']);
   Route::post('/storeredis', [HotelController::class, 'storeInRedis']);
   Route::get('/hotelsredisbydate/{startdate}/{enddate}', [HotelController::class, 'getFromRedisByDate']);


});
