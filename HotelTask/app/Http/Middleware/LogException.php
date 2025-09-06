<?php

namespace App\Http\Middleware;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Mail;
use App\Mail\SlowRequestDetected;
class LogException
{
    protected $slowRequestThreshold = 9000; 
    protected $slowDbThreshold      = 9000; 
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $start = microtime(true);

        DB::listen(function ($query) {
            if ($query->time > $this->slowDbThreshold) {
                Log::warning('Slow DB query detected', [
                    'sql'      => $query->sql,
                    'bindings' => $query->bindings,
                    'time_ms'  => $query->time,
                ]);
            }
        });

        try {
            $response = $next($request);
        } catch (\Throwable $e) {
            Log::error('Exception occurred', [
                'type'    => get_class($e),
                'url'     => $request->fullUrl(),
                'method'  => $request->method(),
                'message' => $e->getMessage(),
                'file'    => $e->getFile(),
                'line'    => $e->getLine(),
                'trace'   => $e->getTraceAsString(),
            ]);

          throw $e;
        }

        $duration = (microtime(true) - $start) * 1000;
        $status   = $response->getStatusCode();

        if ($duration > $this->slowRequestThreshold) {
            $details = [
                'url' => $request->fullUrl(),
                'method' => $request->method(),
                'status' => $status,
                'duration_ms' => (int) $duration,
            ];
        
            Log::warning('Slow request detected', $details);
        
            Mail::to('ayamoinn95@gmail.com')->send(new SlowRequestDetected($details));
        }

        if ($status >= 400) {
            if ($status == 404) {
                Log::warning('Not Found detected', [
                    'url'    => $request->fullUrl(),
                    'method' => $request->method(),
                    'status' => $status,
                ]);
            } elseif ($status == 408) {
                Log::warning('Request Timeout detected', [
                    'url'    => $request->fullUrl(),
                    'method' => $request->method(),
                    'status' => $status,
                    'duration_ms' => (int) $duration,
                ]);
            } elseif ($status >= 500) {
                Log::error('Server Error detected', [
                    'url'    => $request->fullUrl(),
                    'method' => $request->method(),
                    'status' => $status,
                    'duration_ms' => (int) $duration,
                ]);
            } else {
                Log::warning('Client Error detected', [
                    'url'    => $request->fullUrl(),
                    'method' => $request->method(),
                    'status' => $status,
                ]);
            }
        }

        return $response;
    }
}
