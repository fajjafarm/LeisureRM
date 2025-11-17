# ===================================================================
# Laravel Fix Script – Run in your project root
# Fixes: 404 homepage, missing login, admin.layout not found, FK errors
# ===================================================================

# 1. Fix migration order (this solves the foreign key error on pool_tests)
Write-Host "Fixing migration order..." -ForegroundColor Cyan

# Rename all migrations with correct chronological order (0001_, 0002_, etc.)
$files = Get-ChildItem "database/migrations" -Filter "*.php" | Sort-Object Name

$i = 1
foreach ($file in $files) {
 $newName = "{0:D4}_00_00_00{1:D4}_{2}" -f 2025, $i, $file.Name.Substring(15)
 Rename-Item -Path $file.FullName -NewName $newName -Force
 $i++
}

# 2. Install Laravel Breeze (gives you login, register, dashboard, etc.)
Write-Host "Installing Laravel Breeze..." -ForegroundColor Cyan
composer require laravel/breeze --dev
php artisan breeze:install blade --dark

# 3. Create the admin layout that everything extends
Write-Host "Creating admin/layout.blade.php..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "resources/views/admin"
Set-Content -Path "resources/views/admin/layout.blade.php" -Value @'
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
'@

# 4. Create a proper welcome page (homepage)
Write-Host "Creating welcome.blade.php..." -ForegroundColor Cyan
Set-Content -Path "resources/views/welcome.blade.php" -Value @'
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
'@

# 5. Fix routes/web.php to have proper homepage and auth routes
Write-Host "Updating routes/web.php..." -ForegroundColor Cyan
$routesContent = @'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProfileController;

// Public homepage
Route::get('/', function () {
 return view('welcome');
})->name('home');

// Breeze authentication routes (login, register, etc.)
require __DIR__.'/auth.php';

// Protected routes
Route ::middleware(['auth', 'verified'])->group(function () {
 Route::get('/dashboard', function () {
 return view('dashboard');
 })->name('dashboard');

 Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
 Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
 Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

 // === YOUR EXISTING ROUTES BELOW (keep everything you already have) ===
 // Example: Route::resource('pool-tests', PoolTestController::class)->parameters(['pool-tests' => 'subFacility']);
 // ... paste the rest of your routes here after this line
});

// If you already have a routes/web.php with lots of routes, just make sure the above is at the top!
'@

# Backup existing routes first
Copy-Item "routes/web.php" "routes/web.php.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
Set-Content -Path "routes/web.php" -Value $routesContent

Write-Host "Backup of old routes saved as routes/web.php.backup.*" -ForegroundColor Yellow

# 6. Final steps
Write-Host ""
Write-Host "ALMOST DONE! Now run these commands in your terminal:" -ForegroundColor Green
Write-Host " php artisan migrate:fresh --seed" -ForegroundColor White
Write-Host " php artisan storage:link" -ForegroundColor White
Write-Host " php artisan view:clear" -ForegroundColor White
Write-Host " php artisan route:clear" -ForegroundColor White
Write-Host " php artisan config:clear" -ForegroundColor White
Write-Host " php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host "Your app should now load at http://localhost:8000 with a proper homepage and working login!" -ForegroundColor Green