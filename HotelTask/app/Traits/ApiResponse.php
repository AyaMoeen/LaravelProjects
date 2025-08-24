<?php
namespace App\Traits;
use Illuminate\Http\Response;

trait ApiResponse {
    protected function successResponse($data = [], $message = 'Success', $code = Response::HTTP_OK) {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

     protected function errorResponse($data = [], $message = 'Error', $code = Response::HTTP_BAD_REQUEST) {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => $data
        ], $code);
    }
}