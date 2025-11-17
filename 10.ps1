# 10-FullDemoSeeder.ps1
Set-Location leisure-facilities-manager

@'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{Business, Facility, SubFacility, User, CoshhChemical, Qualification};
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // 1. Super Admin (works on every business)
        $super = User::create([
            'name' => 'Super Admin',
            'email' => 'admin@leisuremanager.test',
            'password' => bcrypt('password')
        ]);
        Role::findOrCreate('super-admin');
        $super->assignRole('super-admin');

        // 2. Demo Business – Sunshine Leisure Centre
        $business = Business::create([
            'name' => 'Sunshine Leisure Centre',
            'slug' => 'sunshine',
            'contact_email' => 'info@sunshineleisure.co.uk',
            'phone' => '01483 123456'
        ]);

        // 3. Main Facility
        $facility = $business->facilities()->create([
            'name' => 'Sunshine Main Site',
            'slug' => 'main',
            'address' => '1 High Street, Guildford, Surrey',
            'postcode' => 'GU1 3AA'
        ]);

        // 4. Sample Staff
        $manager = User::create(['name' => 'Sarah Johnson', 'email' => 'manager@sunshine.test', 'password' => bcrypt('password')]);
        $lifeguard = User::create(['name' => 'Tom Smith', 'email' => 'lifeguard@sunshine.test', 'password' => bcrypt('password')]);

        // Assign to business
        $manager->profile()->create(['business_id' => $business->id, 'current_facility_id' => $facility->id]);
        $lifeguard->profile()->create(['business_id' => $business->id, 'current_facility_id' => $facility->id]);

        // Roles
        Role::findOrCreate('manager')->assignPermissionTo(Permission::all());
        Role::findOrCreate('lifeguard');
        $manager->assignRole('manager');
        $lifeguard->assignRole('lifeguard');

        // 5. Sub-Facilities (pools, thermal suite, soft play)
        $facility->subFacilities()->createMany([
            ['name' => '25m Main Pool',         'type' => 'pool',        'check_interval_minutes' => 60],
            ['name' => 'Learner Pool',         'type' => 'baby_pool',   'check_interval_minutes' => 60],
            ['name' => 'Sauna',                'type' => 'sauna',       'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Steam Room',           'type' => 'steam_room',  'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Hot Tub',              'type' => 'hot_tub',     'check_interval_minutes' => 30],
            ['name' => 'Soft Play Zone',       'type' => 'soft_play',   'check_interval_minutes' => 120],
        ]);

        // 6. COSHH Chemicals (real examples)
        $business->coshhChemicals()->createMany([
            ['name' => 'Sodium Hypochlorite 14%', 'un_number' => '1791', 'min_stock_level' => 50, 'current_stock_level' => 180],
            ['name' => 'Hydrochloric Acid 32%',  'un_number' => '1789', 'min_stock_level' => 25, 'current_stock_level' => 15],
            ['name' => 'Calcium Chloride Flakes', 'un_number' => null,   'min_stock_level' => 100, 'current_stock_level' => 250],
        ]);

        // 7. Qualifications
        Qualification::create(['name' => 'National Pool Lifeguard Qualification (NPLQ)', 'validity_months' => 24, 'required_training_hours_per_month' => 2]);
        Qualification::create(['name' => 'First Aid at Work', 'validity_months' => 36]);

        \Log::info('Sunshine Leisure Centre demo data seeded successfully!');
    }
}
'@ | Out-File -Encoding utf8 database/seeders/DatabaseSeeder.php

Write-Host "10 - FULL commercial demo seeder created (Sunshine Leisure Centre + staff + pools + COSHH)" -ForegroundColor Green