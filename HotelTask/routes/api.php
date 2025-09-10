   <?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;
use App\Http\Middleware\SetLocale;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;
use App\Services\KafkaService;

Route::get('/slow-request', function () {
   // sleep(10);
    return response()->json(['message' => 'Slow request done!']);
});



Route::post('/send-kafka', function (Request $request) {
    $data = $request->all(); // get JSON payload from Postman

    KafkaService::sendMessage('test-topic', $data);

    return response()->json([
        'status' => 'success',
        'message' => 'Kafka message sent',
        'data' => $data
    ]);
});

Route::get('/test-log', function () {
    Log::error('This is a test error log from /api/test-log');
    return response()->json(['status' => 'log written']);
});

Route::get('/redis-test', function () {
    Redis::set('name', 'AYA');
    return Redis::get('name'); 
});

Route::get('/test/exception', function () {
    throw new \Exception('Test Exception for logging');
});

Route::get('/test/db-slow', function () {
    DB::select('SELECT SLEEP(3)');
    return response()->json(['message' => 'Slow DB query done!']);
});

Route::get('/test/http-timeout', function () {
    try {
        Http::timeout(1)->get('https://httpbin.org/delay/5');
    } catch (\Exception $e) {
        Log::error('HTTP Timeout Test', ['error' => $e->getMessage()]);
    }
    return response()->json(['message' => 'HTTP Timeout test done!']);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware([SetLocale::class, 'auth:sanctum'])->group(function () {
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
    Route::post('/logout', [AuthController::class, 'logout']);
});
