<?php
namespace App\Traits;

trait ApiResponse {
    protected function successResponse($data = [], $message = 'Success', $code = 200) {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

     protected function errorResponse($data = [], $message = 'Error', $code = 400) {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => $data
        ], $code);
    }
}