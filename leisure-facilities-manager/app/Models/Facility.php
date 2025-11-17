<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Activitylog\Traits\LogsActivity;

class Facility extends Model
{
    use SoftDeletes, LogsActivity;

    protected $fillable = ['business_id', 'name', 'slug', 'address', 'postcode', 'is_active'];

    protected $casts = ['is_active' => 'boolean'];

    public function business() { return $this->belongsTo(Business::class); }
    public function subFacilities() { return $this->hasMany(SubFacility::class); }
    public function waterMeterReadings() { return $this->hasMany(WaterMeterReading::class); }
    public function clubHires() { return $this->hasMany(ClubHire::class); }
    public function dailyOverviews() { return $this->hasMany(DailyOverview::class); }
    public function messageBoardPosts() { return $this->hasMany(MessageBoardPost::class); }
}
