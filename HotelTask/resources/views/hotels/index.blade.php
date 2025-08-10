<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hotel Directory</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    @vite('resources/css/app.css')
</head>
<body>

    <div class="header">
        <h1>Hotel Directory</h1>
        @include('layouts.menu') 
        <form action="{{ route('hotels.index') }}" method="GET" class="search-form" style="margin-bottom: 20px;">
            <input
                type="text"
                name="search"
                placeholder="Search...."
                value="{{ request('search') }}"
                style="padding: 8px; width: 320px;"
            >

            <button type="submit" style="padding: 8px 16px;">Search</button>
        </form>
    </div>

    <div class="container">
        @foreach ($hotels as $hotel)
            <a href="{{ route('hotels.show', $hotel->id) }}" class="hotel-card-link">
                <div class="hotel-card">
                    <img src="{{ asset($hotel->image) }}" alt="Hotel image" class="hotel-image">
                    <div class="hotel-info">
                        <h2>{{ $hotel->name }}</h2>
                        <p class="location">{{ $hotel->location }}</p>
                        <p class="description">{{ $hotel->description }}</p>
                        <p class="rating">Rating: {{ $hotel->rating }} ★</p>
                    </div>
                </div>
            </a>
        @endforeach
    </div>

</body>
</html>