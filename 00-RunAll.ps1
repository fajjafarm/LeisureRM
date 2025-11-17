# 00-RunAll.ps1
Write-Host "Creating Leisure Facilities Management Suite..." -ForegroundColor Cyan

$scripts = 2..9 | ForEach-Object { "0$_.ps1" | ForEach-Object { if($_ -like "0*.ps1") {$_} else {"$_"} } }

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "Running $script ..." -ForegroundColor Yellow
        & .\$script
    } else {
        Write-Host "Missing: $script" -ForegroundColor Red
    }
}

Write-Host "Project generation complete! Now run: composer install && php artisan migrate --seed" -ForegroundColor Green