<#
.SYNOPSIS
    Master script to run all table and figure generation scripts in subfolders.

.DESCRIPTION
    Iterates through the subdirectories of 'Tabele':
    1. wykres_1_dekompozycja_energii
    2. wykres_2_IRF_szoku_energetycznego
    3. wykres_3_dekompozycja_historyczna_inflacja
    and runs their respective generation scripts.

.EXAMPLE
    .\run_all_tables.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   GENEROWANIE WSZYSTKICH TABEL I WYKRESOW DO ARTYKULU   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$subfolders = @(
    @{ Name = "Wykres 1 (Dekompozycja cnu)"; Path = "wykres_1_dekompozycja_energii" },
    @{ Name = "Wykres 2 (IRF szoku energii)"; Path = "wykres_2_IRF_szoku_energetycznego" },
    @{ Name = "Wykres 3 (Dekompozycja historyczna)"; Path = "wykres_3_dekompozycja_historyczna_inflacja" }
)

$summary = [System.Collections.Generic.List[PSCustomObject]]::new()
$startTime = Get-Date

foreach ($item in $subfolders) {
    $targetDir = Join-Path $ScriptDir $item.Path
    $targetScript = Join-Path $targetDir "run.ps1"

    if (Test-Path $targetScript) {
        Write-Host "`n>>> Rozpoczynam: $($item.Name)..." -ForegroundColor Cyan
        $t0 = Get-Date
        try {
            & powershell -ExecutionPolicy Bypass -File $targetScript
            if ($LASTEXITCODE -ne 0) {
                throw "Skrypt w $($item.Path) zakonczyl sie kodem bledu $LASTEXITCODE"
            }
            $dur = ((Get-Date) - $t0).TotalSeconds
            $summary.Add([PSCustomObject]@{
                Komponent = $item.Name
                Status    = "SUCCESS"
                Czas      = "$($dur.ToString('F1')) s"
            })
        }
        catch {
            $summary.Add([PSCustomObject]@{
                Komponent = $item.Name
                Status    = "FAILED"
                Czas      = "-"
            })
            Write-Error $_
        }
    } else {
        Write-Warning "Nie znaleziono skryptu: $targetScript"
    }
}

$totalElapsed = ((Get-Date) - $startTime).TotalSeconds
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "                     PODSUMOWANIE                         " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
$summary | Format-Table -AutoSize
Write-Host "Laczny czas: $($totalElapsed.ToString('F1')) s`n" -ForegroundColor Green
