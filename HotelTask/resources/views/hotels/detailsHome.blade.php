<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ $hotel->name }} - Details</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    @vite('resources/css/app.css')
</head>
<body>

    <div class="header">
        <h1>{{ $hotel->name }}</h1>
    </div>

    <div class="container">

        <form method="GET" action="{{ route('hotels.show', $hotel->id) }}" class="price-filter-form">
            <div class="price-fields">
                <input 
                    type="number"
                    name="min_price"
                    placeholder="Min price"
                    value="{{ request('min_price') }}"
                    min="0"
                    step="1"
                >
                <input 
                    type="number"
                    name="max_price"
                    placeholder="Max price"
                    value="{{ request('max_price') }}"
                    min="0"
                    step="1"
                >
                <button type="submit">Filter</button>
            </div>
        </form>

        <h2 class="section-title">Available Rooms</h2>

        <div class="room-list">
            @forelse ($rooms as $room)
                <div class="room-card">
                    <div class="room-body">
                        <h3>{{ $room->type }}</h3>
                        <p class="price">₪{{ number_format($room->price, 2) }} ILS</p>
                        <p class="capacity">Capacity: {{ $room->capacity }} guest{{ $room->capacity > 1 ? 's' : '' }}</p>
                    </div>
                </div>
            @empty
                <p style="margin-top: 20px;">No rooms found in this price range.</p>
            @endforelse
        </div>
    </div>

</body>
</html>
