<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>@yield('title', 'Pool Manager')</title>
 @vite(['resources/css/app.css', 'resources/js/app.js'])
 <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="h-full bg-gray-100">
 <div class="min-h-full">
 @include('layouts.navigation')

 <header class="bg-white shadow">
 <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
 <h1 class="text-3xl font-bold text-gray-900">@yield('header')</h1>
 </div>
 </header>

 <main>
 <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
 @yield('content')
 </div>
 </main>
 </div>
</body>
</html>
