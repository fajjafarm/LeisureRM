# 01-ProjectSetup.ps1
$project = "leisure-suite"
if (!(Test-Path $project)) { mkdir $project -Force }
Set-Location $project

# composer.json - Full commercial stack (Faker in require to avoid seeder errors)
$composerJson = @'
{
    "name": "adafarmio/leisure-suite",
    "description": "Commercial UK H&S compliant leisure & facilities management suite on Laravel 12 + Livewire 3",
    "type": "project",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^12.0",
        "laravel/breeze": "^2.0",
        "laravel/sanctum": "^4.0",
        "livewire/livewire": "^3.5",
        "spatie/laravel-permission": "^6.0",
        "spatie/laravel-activitylog": "^4.8",
        "maatwebsite/excel": "^3.1",
        "barryvdh/laravel-dompdf": "^3.0",
        "fakerphp/faker": "^1.23"
    },
    "require-dev": {
        "laravel/pint": "^1.13",
        "nunomaduro/collision": "^8.1"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
'@

$composerJson | Out-File -Encoding utf8 composer.json

# .env.example
$envExample = @'
APP_NAME="Leisure Facilities Manager"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=leisurerm_	
DB_USERNAME=leisurerm
DB_PASSWORD=^79u5pR1i

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME="${APP_NAME}"
'@

$envExample | Out-File -Encoding utf8 .env.example

# Basic folders
@('app/Http/Controllers', 'app/Http/Livewire', 'app/Models', 'database/migrations', 'database/seeders', 'resources/views/layouts', 'resources/views/livewire', 'public/css', 'public/js') | ForEach-Object { mkdir $_ -Force }

Write-Host "01 - Laravel 12 project setup complete (Faker in require, no dev errors)" -ForegroundColor Green
