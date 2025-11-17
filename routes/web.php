<?php
use Illuminate\Support\Facades\Route;
use App\Http\Livewire\{Dashboard, TaskManager, PoolTesting, MessageBoard, CoshhInventory};

Route::get('/', fn() => redirect('/login'));

Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/dashboard', Dashboard::class)->name('dashboard');
    Route::get('/tasks', TaskManager::class)->name('tasks');
    Route::get('/pool-testing', PoolTesting::class)->name('pool-testing');
    Route::get('/coshh', CoshhInventory::class)->name('coshh');
    Route::get('/message-board', MessageBoard::class)->name('message-board');
});

require __DIR__.'/auth.php';
