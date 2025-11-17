<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{
    Business, Facility, SubFacility, User, UserProfile,
    CoshhChemical, Qualification, SafetyChecklistTemplate,
    DailyOverview, MessageBoardPost
};
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Super Admin (works everywhere)
        $super = User::firstOrCreate(
            ['email' => 'admin@leisuremanager.test'],
            ['name' => 'Super Admin', 'password' => bcrypt('password')]
        );
        Role::findOrCreate('super-admin');
        $super->assignRole('super-admin');

        // 2. Sunshine Leisure Centre (real UK setup)
        $business = Business::create([
            'name' => 'Sunshine Leisure Centre',
            'slug' => 'sunshine',
            'contact_email' => 'info@sunshineleisure.co.uk',
            'phone' => '01483 123456',
            'address' => '1 High Street, Guildford, Surrey, GU1 3AA',
        ]);

        $facility = $business->facilities()->create([
            'name' => 'Sunshine Main Site',
            'slug' => 'main',
            'address' => '1 High Street, Guildford, Surrey',
            'postcode' => 'GU1 3AA',
        ]);

        // 3. Staff
        $manager = User::firstOrCreate(['email' => 'manager@sunshine.test'], ['name' => 'Sarah Johnson', 'password' => bcrypt('password')]);
        $lifeguard = User::firstOrCreate(['email' => 'lifeguard@sunshine.test'], ['name' => 'Tom Smith', 'password' => bcrypt('password')]);
        $reception = User::firstOrCreate(['email' => 'reception@sunshine.test'], ['name' => 'Emma Brown', 'password' => bcrypt('password')]);

        foreach ([$manager, $lifeguard, $reception] as $user) {
            $user->profile()->updateOrCreate(
                ['user_id' => $user->id],
                ['business_id' => $business->id, 'current_facility_id' => $facility->id]
            );
        }

        Role::findOrCreate('manager');
        Role::findOrCreate('lifeguard');
        Role::findOrCreate('reception');
        $manager->assignRole('manager');

        // 4. Sub-Facilities
        $facility->subFacilities()->createMany([
            ['name' => '25m Competition Pool', 'type' => 'pool', 'check_interval_minutes' => 60],
            ['name' => 'Learner Pool', 'type' => 'baby_pool', 'check_interval_minutes' => 60],
            ['name' => 'Sauna', 'type' => 'sauna', 'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Steam Room', 'type' => 'steam_room', 'check_interval_minutes' => 20, 'is_thermal_suite' => true],
            ['name' => 'Hot Tub', 'type' => 'hot_tub', 'check_interval_minutes' => 30],
            ['name' => 'Soft Play Zone', 'type' => 'soft_play', 'check_interval_minutes' => 120],
        ]);

        // 5. COSHH (with deliberate low stock!)
        $business->coshhChemicals()->createMany([
            ['name' => 'Hydrochloric Acid 32%', 'un_number' => '1789', 'min_stock_level' => 25, 'current_stock_level' => 12],
            ['name' => 'Sodium Hypochlorite 14%', 'un_number' => '1791', 'min_stock_level' => 50, 'current_stock_level' => 180],
        ]);

        // 6. Qualifications
        Qualification::createMany([
            ['name' => 'National Pool Lifeguard Qualification (NPLQ)', 'issuing_body' => 'RLSS UK', 'validity_months' => 24, 'required_training_hours_per_month' => 2],
            ['name' => 'First Aid at Work', 'issuing_body' => 'HSE', 'validity_months' => 36],
        ]);

        // 7. Daily Overview (so the message board isnâ€™t empty)
        DailyOverview::updateOrCreate(
            ['facility_id' => $facility->id, 'overview_date' => today()],
            ['expected_guests' => 450, 'staff_on_shift' => [['name' => 'Sarah Johnson', 'start' => '06:00', 'end' => '14:00']]]
        );

        \Log::info('Sunshine Leisure Centre â€“ FULL commercial UK H&S demo seeded!');
    }
}
