<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Contracts\Console\PromptsForMissingInput;

class DeleteHotel extends Command implements PromptsForMissingInput
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'hotel:delete {id}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete hotel using api';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $id = $this->argument('id');
        $api_base = config('app.api_base_url');
        $response = Http::delete("{$api_base}/hotels/{$id}");

        if ($response->successful()) {
            $this->info("Hotel with ID {$id} deleted successfully via API.");
            return Command::SUCCESS;
        }

        $this->error("Hotel Not Found, Status: " . $response->status());
        return Command::FAILURE;
    }
}
