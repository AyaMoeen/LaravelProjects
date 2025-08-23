   <?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;

Route::get('/hotels', [HotelController::class, 'index']);
Route::post('/hotels', [HotelController::class, 'store']);
Route::get('/hotels/{id}',[HotelController::class, 'show']);
Route::delete('/hotels/{id}', [HotelController::class, 'destroy']);
Route::delete('/bulk', [HotelController::class, 'bulkDestroy']);
