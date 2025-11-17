<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>Pool Management System</title>
 @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="antialiased bg-gray-100">
 <div class="relative flex items-top justify-center min-h-screen bg-gray-100 sm:items-center sm:pt-0">
 <div class="max-w-6xl mx-auto sm:px-6 lg:px-8">
 <div class="flex justify-center pt-8 sm:justify-start sm:pt-0">
 <h1 class="text-6xl font-bold text-gray-800">Pool Manager</h1>
 </div>

 <div class="mt-8 bg-white overflow-hidden shadow sm:rounded-lg p-12 text-center">
 <h2 class="text-3xl font-semibold text-gray-700 mb-6">Welcome to your facility management system</h2>
 <div class="space-x-4">
 @guest
 <a href="{{ route('login') }}" class="inline-flex items-center px-6 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700">
 Login
 </a>
 <a href="{{ route('register') }}" class="inline-flex items-center px-6 py-3 bg-gray-600 text-white font-medium rounded-md hover:bg-gray-700">
 Register
 </a>
 @else
 <a href="{{ route('dashboard') }}" class="inline-flex items-center px-6 py-3 bg-green-600 text-white font-medium rounded-md hover:bg-green-700">
 Go to Dashboard
 </a>
 @endguest
 </div>
 </div>
 </div>
 </div>
</body>
</html>
