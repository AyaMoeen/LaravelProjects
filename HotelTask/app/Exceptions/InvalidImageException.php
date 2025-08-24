<?php

namespace App\Exceptions;
use Illuminate\Http\Response;

use Exception;

class InvalidImageException extends Exception
{
    protected $message;
    protected $code;

    public function __construct($message = "Invalid image uploaded", $code = Response::HTTP_BAD_REQUEST)
    {
        parent::__construct($message, $code);
    }
}
