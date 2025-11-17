<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{
    Business, Facility, SubFacility, User, UserProfile,
    CoshhChemical, Qualification, SafetyChecklistTemplate
};
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Super Admin (global access)
        $super = User::firstOrCreate(
            ['email' => 'admin@leisuremanager.test'],
            [
                'name' => 'Super Admin',
                'password' => bcrypt('password')
            ]
        );
        Role::findOrCreate('super-admin');
        $super->assignRole('super-admin');

        // 2. Demo Business – Sunshine Leisure Centre
        $business = Business::create([
            'name' => 'Sunshine Leisure Centre',
            'slug' => 'sunshine',
            'contact_email' => 'info@sunshineleisure.co.uk',
            'phone' => '01483 123456',
            'address' => '1 High Street, Guildford, Surrey, GU1 3AA'
        ]);

        // 3. Main Facility
        $facility = $business->facilities()->create([
            'name' => 'Sunshine Main Site',
            'slug' => 'main',
            'address' => '1 High Street, Guildford, Surrey',
            'postcode' => 'GU1 3AA'
        ]);

        // 4. Staff Users
        $manager = User::firstOrCreate(
            ['email' => 'manager@sunshine.test'],
            ['name' => 'Sarah Johnson', 'password' => bcrypt('password')]
        );
        $lifeguard = User::firstOrCreate(
            ['email' => 'lifeguard@sunshine.test'],
            ['name' => 'Tom Smith', 'password' => bcrypt('password')]
        );
        $reception = User::firstOrCreate(
            ['email' => 'reception@sunshine.test'],
            ['name' => 'Emma Brown', 'password' => bcrypt('password')]
        );

        // Profiles & current facility
        foreach ([$manager, $lifeguard, $reception] as $user) {
            $user->profile()->updateOrCreate(
                ['user_id' => $user->id],
                ['business_id' => $business->id, 'current_facility_id' => $facility->id]
            );
        }

        // 5. Roles & Permissions
        Role::findOrCreate('manager');
        Role::findOrCreate('lifeguard');
        Role::findOrCreate('reception');

        $manager->assignRole('manager');
        $lifeguard->assignRole('lifeguard');
        $reception->assignRole('reception');

        // Give manager full permissions
        $manager->givePermissionTo(Permission::all());

        // 6. Sub-Facilities (real UK leisure setup)
        $facility->subFacilities()->createMany([
            ['name' => '25m Competition Pool',     'type' => 'pool',        'check_interval_minutes' => 60],
            ['name' => 'Learner Pool',             'type' => 'baby_pool',   'check_interval_minutes' => 60],
            ['name' => 'Sauna',                    'type' => 'sauna',       'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Steam Room',               'type' => 'steam_room',  'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Experience Shower',        'type' => 'experience_shower', 'check_interval_minutes' => 30, 'is_thermal_suite' => true],
            ['name' => 'Plunge Pool',              'type' => 'plunge_pool', 'check_interval_minutes' => 30],
            ['name' => 'Hot Tub',                  'type' => 'hot_tub',     'check_interval_minutes' => 30],
            ['name' => 'Soft Play Zone',           'type' => 'soft_play',   'check_interval_minutes' => 120],
            ['name' => 'Gym Floor',                'type' => 'gym',         'check_interval_minutes' => 240],
        ]);

        // 7. COSHH Chemicals (real UK pool chemicals with UN numbers)
        $business->coshhChemicals()->createMany([
            ['name' => 'Sodium Hypochlorite 14%',   'manufacturer' => 'Brenntag', 'un_number' => '1791', 'hazard_symbols' => 'C,N', 'min_stock_level' => 50,  'current_stock_level' => 180, 'storage_location' => 'Chemical Store A'],
            ['name' => 'Hydrochloric Acid 32%',     'manufacturer' => 'Brenntag', 'un_number' => '1789', 'hazard_symbols' => 'C',   'min_stock_level' => 25,  'current_stock_level' => 12,  'storage_location' => 'Chemical Store A'],
            ['name' => 'Calcium Hypochlorite 65%',  'manufacturer' => 'Arch',     'un_number' => '2880', 'hazard_symbols' => 'O,Xi', 'min_stock_level' => 40,  'current_stock_level' => 90,  'storage_location' => 'Chemical Store B'],
            ['name' => 'Sulphuric Acid 96%',        'manufacturer' => 'Brenntag', 'un_number' => '1830', 'hazard_symbols' => 'C',   'min_stock_level' => 20,  'current_stock_level' => 45,  'storage_location' => 'Chemical Store A'],
            ['name' => 'Sodium Bisulphate (pH Reducer)', 'un_number' => null, 'min_stock_level' => 50, 'current_stock_level' => 120],
        ]);

        // 8. Qualifications (UK recognised)
        Qualification::createMany([
            ['name' => 'National Pool Lifeguard Qualification (NPLQ)', 'issuing_body' => 'RLSS UK', 'validity_months' => 24, 'required_training_hours_per_month' => 2],
            ['name' => 'First Aid at Work (FAW)', 'issuing_body' => 'HSE', 'validity_months' => 36],
            ['name' => 'Pool Plant Operator', 'issuing_body' => 'PWTAG', 'validity_months' => 60],
        ]);

        // 9. Safety Checklist Templates (HSG179 / PWTAG)
        $dailyPool = SafetyChecklistTemplate::create([
            'name' => 'Daily Pool Safety Check (HSG179)',
            'frequency' => 'daily',
            'days_before_due_alert' => 1
        ]);
        $dailyPool->items()->createMany([
            ['item_text' => 'Pool water clarity acceptable?', 'requires_photo' => true],
            ['item_text' => 'Emergency phone working?', 'requires_comment_if_no' => true],
            ['item_text' => 'All rescue equipment in place?', 'requires_photo' => true],
        ]);

        $monthlySoftPlay = SafetyChecklistTemplate::create([
            'name' => 'Monthly Soft Play Inspection (BS EN 1176)',
            'frequency' => 'monthly'
        ]);
        $monthlySoftPlay->items()->createMany([
            ['item_text' => 'Impact absorbing surface intact?', 'requires_photo' => true],
            ['item_text' => 'No sharp edges or protruding bolts?', 'requires_photo' => true],
        ]);

        \Log::info('Sunshine Leisure Centre – FULL UK H&S compliant demo seeded successfully!');
    }
}