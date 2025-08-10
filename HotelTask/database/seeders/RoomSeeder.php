<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Hotel;
use App\Models\Room;

class RoomSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $hotel1 = Hotel::Where('name','Yildiz Hotel')->first();
        $hotel2 = Hotel::Where('name','Royal Suites Hotel')->first();
        $hotel3 = Hotel::Where('name','Royal Court Hotel')->first();
        $hotel4 = Hotel::Where('name','Millennium Hotel')->first();
        $hotel5 = Hotel::Where('name','Jacir Palace Hotel')->first();
        $hotel6 = Hotel::Where('name','Queen Plaza Hotel')->first();

        Room::create([
            'hotel_id' => $hotel1->id,
            'type' => 'Single Room',
            'price' => 80.00,
            'capacity' => 1
        ]);
        Room::create([
            'hotel_id' => $hotel1->id,
            'type' => 'Double Room',
            'price' => 120.00,
            'capacity' => 2
        ]);
        Room::create([
            'hotel_id' => $hotel2->id,
            'type' => 'Suite',
            'price' => 200.00,
            'capacity' => 4
        ]);
        Room::create([
            'hotel_id' => $hotel3->id,
            'type' => 'Double Room',
            'price' => 140.00,
            'capacity' => 2
        ]);
        Room::create([
            'hotel_id' => $hotel4->id,
            'type' => 'Executive Suite',
            'price' => 350.00,
            'capacity' => 3
        ]);
        Room::create([
            'hotel_id' => $hotel5->id,
            'type' => 'Presidential Suite',
            'price' => 500.00,
            'capacity' => 5
        ]);
        Room::create([
            'hotel_id' => $hotel6->id,
            'type' => 'Double Room',
            'price' => 100.00,
            'capacity' => 2
        ]);
    }
}
