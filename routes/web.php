<?php

// File: routes/web.php (excerpt)

use App\Http\Controllers\SuperAdminController;
use App\Http\Controllers\PoolTestController;
use Illuminate\Support\Facades\Auth;

Auth::routes();
// etc.

Route::middleware(['auth', 'role:SuperAdmin'])->prefix('superadmin')->group(function () {
    Route::get('/dashboard', [SuperAdminController::class, 'dashboard']);
    // Other routes
});

Route::resource('pool-tests', PoolTestController::class)->parameters(['pool-tests' => 'subFacility']);
Route::resource('chemical-stocks', ChemicalStockController::class);
Route::resource('health-checks', HealthCheckController::class)->parameters(['health-checks' => 'subFacility']);
Route::resource('tasks', TaskController::class);

// Add more as needed

use App\Http\Controllers\QualificationController;
use App\Http\Controllers\TrainingSessionController;
use App\Http\Controllers\TrainingAttendanceController;

// ...

Route::resource('qualifications', QualificationController::class);
Route::post('qualifications/{qualification}/assign-required', [QualificationController::class, 'assignRequired']);

Route::resource('training-sessions', TrainingSessionController::class);
Route::get('training/attend/{session}', [TrainingAttendanceController::class, 'attend'])->name('training.attend'); // For QR link

Route::get('training/history/{user}', [TrainingAttendanceController::class, 'individualHistory']);
Route::get('training/stats/team', [TrainingAttendanceController::class, 'teamStats']);

use App\Http\Controllers\WaterMeterReadingController;

// ...

Route::resource('water-meter-readings', WaterMeterReadingController::class)->parameters(['water-meter-readings' => 'subFacility']);
Route::patch('water-meter-readings/{subFacility}/update-normal', [WaterMeterReadingController::class, 'updateNormalUsage'])->name('water-meter-readings.update-normal');

use App\Http\Controllers\BackwashLogController;

// ...

Route::resource('backwash-logs', BackwashLogController::class)->parameters(['backwash-logs' => 'subFacility']);
Route::patch('backwash-logs/{subFacility}/update-interval', [BackwashLogController::class, 'updateInterval'])->name('backwash-logs.update-interval');

use App\Http\Controllers\ExternalHireClubController;
use App\Http\Controllers\AnnualInspectionItemController;

// ...

Route::resource('external-hire-clubs', ExternalHireClubController::class)->parameters(['external-hire-clubs' => 'facility']);
Route::resource('annual-inspection-items', AnnualInspectionItemController::class);
Route::post('annual-inspection-items/{item}/add-record', [AnnualInspectionItemController::class, 'addRecord'])->name('annual-inspection-items.add-record');
