<#
.SYNOPSIS
    Generates Wykres 3 (Historical inflation decomposition across three DSGE models).
#>
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Wykres 3: Dekompozycja historyczna inflacji (3 modele)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Push-Location $ScriptDir
try {
    Write-Host "-> Uruchamianie generate_chart_3.py..." -ForegroundColor Yellow
    uv run --with numpy,pandas,scipy,matplotlib python "generate_chart_3.py"

    Write-Host "`n[OK] Wykres 3 zakonczony sukcesem." -ForegroundColor Green
}
finally {
    Pop-Location
}
