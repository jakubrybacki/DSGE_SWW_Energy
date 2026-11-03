<#
.SYNOPSIS
    Generates Wykres 1 (Energy decomposition tables and charts).
#>
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Wykres 1: Dekompozycja wplywu cnu na inflacje (2022-2023)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Push-Location $ScriptDir
try {
    Write-Host "-> Uruchamianie generuj_tabele_i_wykres.py..." -ForegroundColor Yellow
    uv run --with numpy,pandas,matplotlib python "generuj_tabele_i_wykres.py"

    Write-Host "`n-> Uruchamianie generuj_wykres_slupkowy.py..." -ForegroundColor Yellow
    uv run --with numpy,pandas,matplotlib python "generuj_wykres_slupkowy.py"

    Write-Host "`n[OK] Wykres 1 zakonczony sukcesem." -ForegroundColor Green
}
finally {
    Pop-Location
}
