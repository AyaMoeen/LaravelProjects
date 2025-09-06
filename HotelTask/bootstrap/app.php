<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;
use Illuminate\Routing\Middleware\SubstituteBindings;
use App\Http\Middleware\LogException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php', 
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(prepend: [
          
            'throttle:api',
            SubstituteBindings::class,
        ]);

        $middleware->append(LogException::class);

        $middleware->alias([
            'auth' => \App\Http\Middleware\Authenticate::class,
            'log.exception' => \App\Http\Middleware\LogException::class,
  
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
