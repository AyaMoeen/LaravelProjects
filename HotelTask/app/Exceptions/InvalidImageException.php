<?php

namespace App\Exceptions;

use Exception;

class InvalidImageException extends Exception
{
    protected $message;
    protected $code;

    public function __construct($message = "Invalid image uploaded", $code = 400)
    {
        parent::__construct($message, $code);
    }
}
