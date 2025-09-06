<!DOCTYPE html>
<html>
<head>
    <title>Slow Request Detected</title>
</head>
<body>
    <h2>⚠️ Slow Request Alert</h2>
    <p><strong>URL:</strong> {{ $details['url'] }}</p>
    <p><strong>Method:</strong> {{ $details['method'] }}</p>
    <p><strong>Status:</strong> {{ $details['status'] }}</p>
    <p><strong>Duration:</strong> {{ $details['duration_ms'] }} ms</p>
</body>
</html>
