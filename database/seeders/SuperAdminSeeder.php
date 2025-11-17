<?php 
namespace Database\SuperSeeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Spatie\Permission\Models\Role;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        // Create the SuperAdmin role
        Role::firstOrCreate(['name' => 'SuperAdmin']);

        // Create the super admin user
        $user = User::firstOrCreate(
            ['email' => 'superadmin@example.com'],
            [
                'name' => 'Super Admin',
                'email' => 'superadmin@example.com',
                'password' => bcrypt('password'), // change this later!
                'rank' => 'Resort Director',
            ]
        );

        // Assign the role
        $user->assignRole('SuperAdmin');

        \Log::info('SuperAdmin user created/verified: superadmin@example.com');
    }
}
