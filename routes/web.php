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
Route::group(['prefix' => '/', 'middleware' => 'auth'], function () {
    Route::get('', [RoutingController::class, 'index'])->name('root');
    Route::get('/home', fn()=>view('dashboards.index'))->name('home');
    Route::get('{first}/{second}/{third}', [RoutingController::class, 'thirdLevel'])->name('third');
    Route::get('{first}/{second}', [RoutingController::class, 'secondLevel'])->name('second');
    Route::get('{any}', [RoutingController::class, 'root'])->name('any');
});
Route::get('/qr/scan/{subFacility}', function(App\Models\SubFacility $subFacility) {
    return view('qr.scan', compact('subFacility'));
})->name('qr.scan');
