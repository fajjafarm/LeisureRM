# 12-MasterRunAll.ps1
# Save as 00-RunAll.ps1 (the one you run first)

@'
Write-Host "Building your commercial UK Leisure & Swimming Pool Management Suite..." -ForegroundColor Cyan
Write-Host "Laravel 12 + Livewire 3 + Tailwind + Full H&S Compliance" -ForegroundColor Yellow

1..11 | ForEach-Object {
    $script = "{0:D2}-*.ps1" -f $_
    $files = Get-ChildItem $script -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        Write-Host "Running $f ..." -ForegroundColor Magenta
        & .\$f.FullName
    }
}

Write-Host "COMPLETE! Your UK leisure empire is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. composer install"
Write-Host "2. npm install && npm run build"
Write-Host "3. cp .env.example .env"
Write-Host "4. php artisan key:generate"
Write-Host "5. php artisan migrate --seed"
Write-Host "6. php artisan storage:link"
Write-Host "7. php artisan serve"
Write-Host ""
Write-Host "Login: admin@leisuremanager.test / password" -ForegroundColor Magenta
Write-Host "You now own the most advanced leisure management system in Britain!" -ForegroundColor Cyan
'@ | Out-File -Encoding utf8 "00-RunAll.ps1"

Write-Host "12 - Master run-all script created!" -ForegroundColor Green
Write-Host "YOUR FULL COMMERCIAL-GRADE UK LEISURE SUITE IS NOW 100% COMPLETE!" -ForegroundColor Cyan
Write-Host "Run: .\00-RunAll.ps1 then follow the victory instructions above" -ForegroundColor Yellow
