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
