# 01-Setup-Composer.ps1
Write-Host "1/10 – Installing packages & updating composer.json" -ForegroundColor Yellow
function W($p,$c){$d=Split-Path $p -Parent;if(!(Test-Path $d)){md $d -Force|Out-Null};Set-Content -Path $p -Value $c.Trim() -Encoding UTF8 -Force;Write-Host "Created: $p" -F Green}

W "composer.json" '{
    "name": "adafarmio/leisure-suite",
    "description": "Complete UK Leisure Facility Management Suite",
    "type": "project",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^12.0",
        "livewire/livewire": "^3.5",
        "spatie/laravel-permission": "^6.0",
        "spatie/laravel-activitylog": "^4.0",
        "simplesoftwareio/simple-qrcode": "^4.2",
        "barryvdh/laravel-dompdf": "^3.0",
        "maatwebsite/excel": "^3.1",
        "intervention/image": "^3.0"
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
        ]
    },
    "config": {
        "optimize-autoloader": true,
        "sort-packages": true
    }
}'

composer update --no-interaction
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force
php artisan vendor:publish --provider="Barryvdh\DomPDF\ServiceProvider" --force
php artisan vendor:publish --provider="Maatwebsite\Excel\ExcelServiceProvider" --force
Write-Host "1/10 COMPLETE – Run 02-User-Model.ps1 next" -ForegroundColor Cyan