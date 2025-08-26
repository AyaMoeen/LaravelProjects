<?php

namespace App\Logging;

use Illuminate\Log\Logger as IlluminateLogger;
use Illuminate\Support\Facades\Log;
use Monolog\Handler\StreamHandler;

class LogFile
{
    public $maxBytes =  100 * 1024 ;

    public function __invoke(IlluminateLogger $logger)
    {

        /** @var \Monolog\Logger $monolog */
        $monolog = $logger->getLogger();

         
        foreach ($monolog->getHandlers() as $handler) {
            if ($handler instanceof StreamHandler) {

               
                $filePath = method_exists($handler, 'getUrl') ? $handler->getUrl() : null;

                $actualSize = file_exists($filePath) ? filesize($filePath) : 0;

                
                if ($filePath && ($actualSize > $this->maxBytes)) {
                  

                    $archived = $filePath . '.backup_' . date('Y-m-d_H-i-s');
                    rename($filePath, $archived);
                    file_put_contents($filePath, ""); 

                    Log::info("Log rotated. Old log archived as: $archived");
                } 

                
            }
        }
    }
}