# 11-FinalFixes.ps1
# # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# Publish Spatie Permission migrations (critical!)
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --tag="migrations" --force

# Publish Breeze views (so our layout overrides work)
php artisan vendor:publish --tag=breeze-views --force

# Create missing models for MessageBoardPost & DailyOverview
@'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class MessageBoardPost extends Model {
    protected $fillable = ['facility_id','user_id','message'];
    public function user() { return $this->belongsTo(User::class); }
}

class DailyOverview extends Model {
    protected $fillable = ['facility_id','overview_date','expected_guests','staff_on_shift'];
    protected $casts = ['overview_date'=>'date', 'staff_on_shift'=>'array'];
}
'@ | Out-File -Encoding utf8 app/Models/MessageModels.php

Write-Host "11 - Spatie migrations published + missing models created" -ForegroundColor Green
