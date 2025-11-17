<?php namespace App\Models; use Illuminate\Database\Eloquent\Model; class IncidentReport extends Model { protected $fillable=["sub_facility_id","type","description","actions_taken","user_id"]; }
