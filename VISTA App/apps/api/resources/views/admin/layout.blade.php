<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>لوحة تحكم Vista</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Alexandria:wght@300;400;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { font-family: 'Alexandria', sans-serif; }
    </style>
</head>
<body class="bg-slate-100 text-slate-900">
    <div class="min-h-screen">
        <header class="bg-white shadow-sm">
            <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
                <h1 class="text-xl font-semibold">Vista — لوحة التحكم</h1>
                <span class="text-sm text-slate-500">نسخة مبدئية</span>
            </div>
        </header>
        <main class="max-w-6xl mx-auto px-6 py-8">
            @yield('content')
        </main>
    </div>
</body>
</html>
