   <?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;

Route::delete('/hotels/{id}', [HotelController::class, 'destroy']);
