<#
.SYNOPSIS
    Executes the SWW energy and food model pipeline: step_1_run_model.m and step_2_validate_model.m.

.DESCRIPTION
    Runs MATLAB with Dynare to simulate the energy and food model (step 1) and validate structural
    identities, zero-food baseline nesting, and generate IRF charts (step 2).

.PARAMETER DynarePath
    Path to Dynare MATLAB directory. Defaults to C:\dynare\7.1\matlab (or auto-detected under C:\dynare).

.PARAMETER Interactive
    Switch to run MATLAB interactively.

.EXAMPLE
    .\run_steps.ps1
    Runs both steps in batch mode in the console.

.EXAMPLE
    .\run_steps.ps1 -Interactive
    Launches MATLAB in interactive mode.
#>
[CmdletBinding()]
param(
    [string]$DynarePath = "",
    [switch]$Interactive
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " SWW Energy & Food Model: Running step_1 and step_2" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Locate MATLAB executable
Get-ChildItem -Path $ScriptDir -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $ScriptDir -Filter "bytecode" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$matlabCmd = Get-Command matlab -ErrorAction SilentlyContinue
if (-not $matlabCmd) {
    Write-Error "MATLAB executable not found in PATH. Please ensure MATLAB is installed and in PATH."
    exit 1
}
Write-Host "[OK] MATLAB found: $($matlabCmd.Source)" -ForegroundColor Green

# 2. Locate Dynare MATLAB folder
if (-not $DynarePath) {
    $candidates = @(
        "C:\dynare\7.1\matlab",
        "C:\dynare\*\matlab",
        "C:\Program Files\dynare\*\matlab"
    )
    foreach ($cand in $candidates) {
        $resolved = Get-Item $cand -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved -and (Test-Path (Join-Path $resolved.FullName "dynare.m"))) {
            $DynarePath = $resolved.FullName
            break
        }
    }
}

if (-not $DynarePath -or -not (Test-Path (Join-Path $DynarePath "dynare.m"))) {
    Write-Error "Dynare not found at '$DynarePath'. Please specify -DynarePath '<path_to_dynare\matlab>'."
    exit 1
}
Write-Host "[OK] Dynare found: $DynarePath" -ForegroundColor Green

# Normalize paths for MATLAB
$matlabDynarePath = $DynarePath.Replace("\", "/")
$matlabModelDir   = $ScriptDir.Replace("\", "/")

# 3. Construct MATLAB commands
$commands = @(
    "addpath('$matlabDynarePath');",
    "cd('$matlabModelDir');",
    "fprintf('\n[STEP 1/2] Simulating SWW energy & food model...\n');",
    "step_1_run_model;",
    "fprintf('\n[STEP 2/2] Validating identities, baseline nesting, and plotting IRFs...\n');",
    "step_2_validate_model;"
)
$fullCommand = ($commands -join " ")

# 4. Execute
if ($Interactive) {
    Write-Host "`nLaunching MATLAB in interactive mode..." -ForegroundColor Yellow
    Start-Process matlab -ArgumentList "-r", "`"$fullCommand`""
    Write-Host "[OK] MATLAB process started." -ForegroundColor Green
} else {
    Write-Host "`nExecuting in MATLAB batch mode..." -ForegroundColor Yellow
    $startTime = Get-Date

    & matlab -batch "$fullCommand"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "MATLAB exited with error code $LASTEXITCODE."
        exit $LASTEXITCODE
    }

    $elapsed = (Get-Date) - $startTime
    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host " Pipeline completed successfully in $($elapsed.TotalSeconds.ToString('F1')) s!" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
}
