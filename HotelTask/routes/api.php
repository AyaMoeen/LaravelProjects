   <?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;

Route::get('/', [HotelController::class, 'index']);
Route::get('/hotels/{id}',[HotelController::class, 'show']);
Route::delete('/hotels/{id}', [HotelController::class, 'destroy']);
