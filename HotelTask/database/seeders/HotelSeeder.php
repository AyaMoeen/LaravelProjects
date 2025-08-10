<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Hotel;

class HotelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Hotel::create([
            'name' => 'Yildiz Hotel',
            'location' => 'Beit Wazan, Nablus',
            'description' => 'Yildiz Palace Hotel is one of the most luxurious and famous hotels in Nablus. 
                                It boasts a prime and strategic location. The hotel features elegant rooms
                                 with stunning views, as well as the renowned Babylon Restaurant, the premier
                                  choice for delicious oriental and exotic cuisine.',
            'rating' => 4.5,
            'image' => 'uploads/hotels/YildizHotel.jpg',

        ]);

        Hotel::create([
            'name' => 'Royal Suites Hotel',
            'location' => 'Rafidia, Nablus',
            'description' => 'The Royal Suites Hotel is located in Nablus, in the Rafidia area, 
                                next to Al-Rawda Mosque. One of the most important features of 
                                this area is its lively atmosphere, its proximity to shops, 
                                restaurants, and public parks, and its proximity to the city 
                                center and the historic Old City.',
            'rating' => 4,
            'image' => 'uploads/hotels/RoyalSuitesHotel.jpg',

        ]);

        Hotel::create([
            'name' => 'Royal Court Hotel',
            'location' => 'downtown, Ramallah',
            'description' => 'Royal Court Hotel the home of the popular Vintage
                                Cafe & Sushi & work restaurants',
            'rating' => 4.5,
            'image' => 'uploads/hotels/RoyalCourtHotel.jpg',

        ]);

        Hotel::create([
            'name' => 'Millennium Hotel',
            'location' => 'Almsyoun, Ramallah',
            'description' => 'Millennium Hotel Ramallah is one of the Millennium chain hotels in
                                 the world. is ideally located in the business and diplomatic 
                                 district of Al Masyoun, just minutes away from the city center,
                                  and approximately 1.5 km away from the citys shopping and 
                                  entertainment district. 
                                  This upscale 5 star hotel is the only 5*International 
                                  hotel in the Palestine spans a total of 9665sqm.',
            'rating' => 5,
            'image' => 'uploads/hotels/MillenniumHotel.jpg',

        ]);

        Hotel::create([
            'name' => 'Jacir Palace Hotel',
            'location' => 'jerusalem-Hebron road, Bethlehem',
            'description' => 'The Jacir Palace Hotel in Bethlehem is a monumental landmark 
                                entwining the noble Arab culture with grand architecture.
                                 The hotel is walking distance from the Church of Nativity
                                  and a short drive to the old city of Jerusalem.',
            'rating' => 5,
            'image' => 'uploads/hotels/JacirHotel.jpg',

        ]);

        Hotel::create([
            'name' => 'Queen Plaza Hotel',
            'location' => 'Hebron',
            'description' => 'The QPH Hotel is located in the heart of Hebron, one of the largest
                                and most vibrant cities in the West Bank. Its stunning historical
                                and religious sites make it stand out from the crowd. Book with
                                us for business and pleasure and enjoy our unparalleled service,
                                which is part of the hotels policy.',
            'rating' => 3.5,
            'image' => 'uploads/hotels/QPlazaHotel.jpg',

        ]);
    }
}
