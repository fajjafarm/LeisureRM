<?php

// File: app/Console/Kernel.php (for cron reminders)

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use App\Models\SubFacility;
use Illuminate\Support\Facades\Mail;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule): void
    {
        $schedule->call(function () {
            SubFacility::all()->each(function ($sub) {
                $lastCheck = $sub->healthChecks()->latest()->first();
                if ($lastCheck && now()->diffInMinutes($lastCheck->checked_at) > $sub->check_interval_minutes
                    && now()->between($sub->check_start_time, $sub->check_end_time)) {
                    // Send email reminder
                    Mail::to('admin@example.com')->send(new \App\Mail\OverdueCheck($sub));
                }
            });
        })->everyMinute(); // Or hourly

        // Existing schedules...

        $schedule->call(function () {
            SubFacility::all()->each(function ($sub) {
                $lastBackwash = $sub->backwashLogs()->latest()->first();
                if ($lastBackwash && now()->diffInDays($lastBackwash->date) > $sub->backwash_interval_days) {
                    // Create task or email
                    app(BackwashLogController::class)->createOverdueTask($sub);
                }
            });
        })->daily(); // Or as needed

        $schedule->call(function () {
            // External Hire Reminders
            ExternalHireDocument::where('is_current', true)
                ->where('expiry_date', '<', now()->addDays(30)) // Remind 30 days before expiry
                ->get()
                ->each(function ($doc) {
                    $existing = Task::where('title', 'like', "%Renew {$doc->type} for {$doc->club->name}%")->where('status', 'Pending')->first();
                    if ($existing) return;

                    Task::create([
                        'title' => "Renew {$doc->type} for {$doc->club->name}",
                        'description' => "Expiry: {$doc->expiry_date}. Please refresh details.",
                        'priority' => 'High',
                        'assigned_to_rank' => 'Manager',
                        'status' => 'Pending',
                        'assigner_id' => 1, // System
                    ]);
                });

            // Annual Inspection Reminders
            AnnualInspectionItem::all()->each(function ($item) {
                $last = $item->lastRecord();
                if ($last && now()->diffInYears($last->date) >= $item->inspection_interval_years) {
                    $existing = Task::where('title', 'like', "%Annual Inspection for {$item->name}%")->where('status', 'Pending')->first();
                    if ($existing) return;

                    Task::create([
                        'title' => "Annual Inspection Overdue for {$item->name}",
                        'description' => "Last inspection: {$last->date}. Schedule new.",
                        'priority' => 'High',
                        'assigned_to_rank' => 'Manager',
                        'status' => 'Pending',
                        'assigner_id' => 1,
                    ]);
                }
            });
        })->yearly(); // Or monthly for checks
    }
}
