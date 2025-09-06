<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests\loginrequest;
use App\Models\User;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Http\Requests\SignupRequest;
use App\Traits\ApiResponse;
use Symfony\Component\HttpFoundation\Response;
class AuthController extends Controller
{
    use ApiResponse;
    public function login(loginrequest $request)
    {
        try {
        $user = User::where('email', $request->email)->first();
    
        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->errorResponse('Invalid credentials', Response::HTTP_UNAUTHORIZED);
        }

        $token = $user->createToken('auth_token')->plainTextToken;
        return $this->successResponse([
                        'token' => $token,
                        'token_type' => 'Bearer',
                        'user' => new UserResource($user) 
                    ], 'User logged in successfully', Response::HTTP_OK);
        } catch (\Exception $e) {
            Log::error('Unexpected error in Auth@login: ' . $e->getMessage(), [
                'exception' => $e,
                'trace'     => $e->getTraceAsString()
            ]);
            return $this->errorResponse('Failed to login, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function register(SignupRequest $request)
    {
        try {
        $user = new User();

        $user->fill([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $user->save();

        
        $token = $user->createToken('auth_token')->plainTextToken;
        return $this->successResponse([], 'User registered successfully', Response::HTTP_CREATED);
        } catch (\Exception $e) {
            Log::error('Unexpected error in Auth@register: ' . $e->getMessage(), [
                'exception' => $e,
                'trace'     => $e->getTraceAsString()
            ]);
            return $this->errorResponse('Failed to register, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return $this->successResponse([],'User logged out successfully', Response::HTTP_OK);

        } catch (\Exception $e) {
            Log::error('Unexpected error in Auth@logout: ' . $e->getMessage(), [
                'exception' => $e,
                'trace'     => $e->getTraceAsString()
            ]);
            return $this->errorResponse('Failed to logout, please try again.', Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
}
