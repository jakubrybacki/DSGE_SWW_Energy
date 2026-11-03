<#
.SYNOPSIS
    Generates Wykres 2 (Energy shock IRF decomposition charts).
#>
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Wykres 2: Dekompozycja IRF szoku energetycznego" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Push-Location $ScriptDir
try {
    Write-Host "-> Uruchamianie generate_chart_2.py..." -ForegroundColor Yellow
    uv run --with numpy,pandas,scipy,matplotlib python "generate_chart_2.py"

    Write-Host "`n[OK] Wykres 2 zakonczony sukcesem." -ForegroundColor Green
}
finally {
    Pop-Location
}
