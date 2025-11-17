# 00-RunAll.ps1 - FINAL WORKING VERSION
Write-Host "UK Leisure Suite Builder - Starting..." -ForegroundColor Cyan

$scripts = @(
    "01-ProjectSetup.ps1"
    "02-Migrations1.ps1"
    "03-Migrations2.ps1"
    "04-FinalMigrations-Models.ps1"
    "05-LayoutSidebar.ps1"
    "06-TasksPoolTesting.ps1"
    "07-TimersCoshhExports.ps1"
    "08-MessageBoardRoutes.ps1"
    "09-CommercialSeeder.ps1"
    "10-ViteFinalSetup.ps1"
    "11-FinalFixes.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "Running $script ..." -ForegroundColor Yellow
        & .\$script
        Write-Host "$script - DONE" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $script NOT FOUND!" -ForegroundColor Red
        pause
        exit
    }
}

Write-Host "ALL 11 SCRIPTS COMPLETED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host "Your UK Leisure Suite is now fully built!" -ForegroundColor Green
Write-Host ""
Write-Host "Now run these commands:" -ForegroundColor Yellow
Write-Host "composer install"
Write-Host "npm install && npm run build"
Write-Host "copy .env.example .env"
Write-Host "php artisan key:generate"
Write-Host "php artisan migrate --seed"
Write-Host "php artisan storage:link"
Write-Host "php artisan serve"
Write-Host ""
Write-Host "Login: admin@leisuremanager.test / password" -ForegroundColor Magenta
Write-Host "You did it, boss!" -ForegroundColor Cyan