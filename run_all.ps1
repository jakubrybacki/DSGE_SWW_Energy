<#
.SYNOPSIS
    Master orchestration script for the DSGE models research pipeline.

.DESCRIPTION
    Automates the end-to-end DSGE research pipeline across all components:
    1. Data preparation (Eurostat & BIS download and transfer to models via R scripts).
    2. Calibration synchronization (Calibrations.xlsx -> Dynare .mod via Python generators).
    3. Model execution and validation (SWW_klasyczny, SWW_energia_w_produkcji, SWW_energia_zywnosc).

.PARAMETER Country
    Country or geography code (default: 'EA' or 'EA20'). Examples: 'EA', 'EA20', 'PL'.

.PARAMETER Models
    List of models to run. Accepts 'all' (default), or any combination of:
    - 'classic' (alias: 'klasyczny', 'sww_klasyczny')
    - 'energy'  (alias: 'energia', 'sww_energia_w_produkcji')
    - 'food'    (alias: 'zywnosc', 'sww_energia_zywnosc')

.PARAMETER SkipData
    Switch to skip downloading and transferring Eurostat data (Stage 1).

.PARAMETER SkipCalibration
    Switch to skip generating .mod calibration input files from Calibrations.xlsx (Stage 2).

.PARAMETER Interactive
    Switch to run MATLAB interactively (opens MATLAB GUI, keeping plots open).

.PARAMETER SavePlots
    Switch to export generated figures to PNG images (e.g. in SWW_klasyczny/figures).

.PARAMETER DynarePath
    Custom path to the Dynare MATLAB directory (e.g., C:\dynare\7.1\matlab).
    If omitted, auto-detected under C:\dynare and C:\Program Files\dynare.

.PARAMETER RscriptExecutable
    Custom path to Rscript.exe (auto-detected via PATH if omitted).

.PARAMETER PythonExecutable
    Custom path to python.exe (auto-detected if omitted).

.EXAMPLE
    .\run_all.ps1
    Runs the full pipeline for all models using EA20 data in batch mode.

.EXAMPLE
    .\run_all.ps1 -SkipData -Models classic,energy
    Skips data download, syncs calibration, and runs classic and energy models.

.EXAMPLE
    .\run_all.ps1 -SkipData -SkipCalibration -Models classic -SavePlots
    Runs only the classic model and saves all IRF figures to SWW_klasyczny/figures/.

.EXAMPLE
    .\run_all.ps1 -Country PL -Models classic
    Runs the pipeline for Poland.
#>
[CmdletBinding()]
param(
    [string]$Country = "EA",
    [string[]]$Models = @("all"),
    [switch]$SkipData,
    [switch]$SkipCalibration,
    [switch]$Interactive,
    [switch]$SavePlots,
    [string]$DynarePath = "",
    [string]$RscriptExecutable = "",
    [string]$PythonExecutable = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }

# Normalize Country name (EA -> EA20)
$geoNorm = $Country.Trim().ToUpperInvariant()
if ($geoNorm -eq "EA") { $geoNorm = "EA20" }

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "                     DSGE RESEARCH PIPELINE ORCHESTRATOR                        " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " Target Country : $geoNorm (input: '$Country')" -ForegroundColor White
Write-Host " Mode           : $(if ($Interactive) { 'Interactive (MATLAB GUI)' } else { 'Batch (Headless)' })" -ForegroundColor White
Write-Host " Save Plots     : $(if ($SavePlots) { 'Yes (PNG export)' } else { 'No' })" -ForegroundColor White
Write-Host " Skip Data      : $SkipData" -ForegroundColor White
Write-Host " Skip Calib     : $SkipCalibration" -ForegroundColor White

# -----------------------------------------------------------------------------
# 1. Resolve Models to Run
# -----------------------------------------------------------------------------
$modelMap = @{
    'all'                     = @('classic', 'energy', 'food')
    'classic'                 = @('classic')
    'klasyczny'               = @('classic')
    'sww_klasyczny'           = @('classic')
    'energy'                  = @('energy')
    'energia'                 = @('energy')
    'sww_energia_w_produkcji' = @('energy')
    'food'                    = @('food')
    'zywnosc'                 = @('food')
    'sww_energia_zywnosc'     = @('food')
}

$selectedModels = [System.Collections.Generic.List[string]]::new()
foreach ($m in $Models) {
    if ($m -contains ",") {
        $parts = $m.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries)
    } else {
        $parts = @($m)
    }
    foreach ($p in $parts) {
        $key = $p.Trim().ToLowerInvariant()
        if ($modelMap.ContainsKey($key)) {
            foreach ($target in $modelMap[$key]) {
                if (-not $selectedModels.Contains($target)) {
                    $selectedModels.Add($target)
                }
            }
        } else {
            Write-Error "Unknown model option '$p'. Available choices: all, classic, energy, food."
            exit 1
        }
    }
}

Write-Host " Selected Models: $($selectedModels -join ', ')" -ForegroundColor White
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray

# -----------------------------------------------------------------------------
# 2. Dependency Discovery
# -----------------------------------------------------------------------------
Write-Host "`n[1/4] Checking tools and prerequisites..." -ForegroundColor Yellow

# MATLAB
$matlabCmd = Get-Command matlab -ErrorAction SilentlyContinue
if (-not $matlabCmd) {
    Write-Error "MATLAB executable not found in PATH. Please ensure MATLAB is installed."
    exit 1
}
Write-Host "  [OK] MATLAB: $($matlabCmd.Source)" -ForegroundColor Green

# Dynare
if (-not $DynarePath) {
    $dynareCandidates = @(
        "C:\dynare\7.1\matlab",
        "C:\dynare\*\matlab",
        "C:\Program Files\dynare\*\matlab"
    )
    foreach ($cand in $dynareCandidates) {
        $resolved = Get-Item $cand -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved -and (Test-Path (Join-Path $resolved.FullName "dynare.m"))) {
            $DynarePath = $resolved.FullName
            break
        }
    }
}
if (-not $DynarePath -or -not (Test-Path (Join-Path $DynarePath "dynare.m"))) {
    Write-Error "Dynare not found. Please provide -DynarePath '<path_to_dynare\matlab>'."
    exit 1
}
Write-Host "  [OK] Dynare: $DynarePath" -ForegroundColor Green

# Rscript (only required if not skipping data)
if (-not $SkipData) {
    if (-not $RscriptExecutable) {
        $rCmd = Get-Command Rscript -ErrorAction SilentlyContinue
        if ($rCmd) {
            $RscriptExecutable = $rCmd.Source
        } else {
            $rCandidates = @("C:\Program Files\R\R-*\bin\Rscript.exe")
            $resolvedR = Get-Item $rCandidates -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($resolvedR) { $RscriptExecutable = $resolvedR.FullName }
        }
    }
    if (-not $RscriptExecutable -or -not (Test-Path $RscriptExecutable)) {
        Write-Error "Rscript executable not found. Install R or specify -RscriptExecutable."
        exit 1
    }
    Write-Host "  [OK] Rscript: $RscriptExecutable" -ForegroundColor Green
}

# Python (only required if not skipping calibration)
if (-not $SkipCalibration) {
    if (-not $PythonExecutable) {
        $bundled = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
        if (Test-Path -LiteralPath $bundled) {
            $PythonExecutable = $bundled
        } else {
            $pyCmd = Get-Command python -ErrorAction SilentlyContinue
            if ($pyCmd) { $PythonExecutable = $pyCmd.Source }
        }
    }
    if (-not $PythonExecutable) {
        Write-Error "Python executable not found. Install Python or specify -PythonExecutable."
        exit 1
    }
    Write-Host "  [OK] Python: $PythonExecutable" -ForegroundColor Green
}

# Track pipeline status and timings
$summaryReport = [System.Collections.Generic.List[PSCustomObject]]::new()
$pipelineStartTime = Get-Date

# -----------------------------------------------------------------------------
# 3. Stage 1: Data Download and Transfer
# -----------------------------------------------------------------------------
if (-not $SkipData) {
    Write-Host "`n[2/4] Stage 1: Data Preparation for geography '$geoNorm'..." -ForegroundColor Yellow
    $stage1Timer = Get-Date

    # Step 1: Download & Transform
    Write-Host "  -> Running step1_download_eurostat.R..." -ForegroundColor Cyan
    $step1Path = Join-Path $ScriptDir "data\step1_download_eurostat.R"
    & $RscriptExecutable $step1Path "--geo=$geoNorm" "--install=true"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "step1_download_eurostat.R failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }

    # Step 2: Transfer to Models
    Write-Host "  -> Running step2_transfer_to_models.R..." -ForegroundColor Cyan
    $step2Path = Join-Path $ScriptDir "data\step2_transfer_to_models.R"
    & $RscriptExecutable $step2Path "--geo=$geoNorm" "--install=true"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "step2_transfer_to_models.R failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }

    $elapsedStage1 = ((Get-Date) - $stage1Timer).TotalSeconds
    Write-Host "  [SUCCESS] Stage 1 completed in $($elapsedStage1.ToString('F1')) s." -ForegroundColor Green
    $summaryReport.Add([PSCustomObject]@{
        Stage   = "Data Prep (Eurostat & Transfer)"
        Status  = "SUCCESS"
        Elapsed = "$($elapsedStage1.ToString('F1')) s"
    })
} else {
    Write-Host "`n[2/4] Stage 1: Data Preparation SKIPPED (-SkipData)." -ForegroundColor DarkGray
    $summaryReport.Add([PSCustomObject]@{
        Stage   = "Data Prep (Eurostat & Transfer)"
        Status  = "SKIPPED"
        Elapsed = "-"
    })
}

# -----------------------------------------------------------------------------
# 4. Stage 2: Calibration Synchronization
# -----------------------------------------------------------------------------
if (-not $SkipCalibration) {
    Write-Host "`n[3/4] Stage 2: Calibration Synchronization for geography '$geoNorm'..." -ForegroundColor Yellow
    $stage2Timer = Get-Date

    # Main calibration generator (SWW_klasyczny & SWW_energia_w_produkcji)
    $calibScript = Join-Path $ScriptDir "calibration\generate_mod_inputs.ps1"
    $calibParams = @{
        Country          = $geoNorm
        PythonExecutable = $PythonExecutable
    }
    if (Test-Path $calibScript) {
        Write-Host "  -> Generating Dynare input modules from root Calibrations.xlsx..." -ForegroundColor Cyan
        & powershell -ExecutionPolicy Bypass -File $calibScript @calibParams
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Root calibration generation failed with exit code $LASTEXITCODE."
            exit $LASTEXITCODE
        }
    } else {
        Write-Host "  -> Root calibration generator ($calibScript) not found; keeping existing Estimation_Setup modules." -ForegroundColor Gray
    }

    # Food model calibration generator (if food model is selected and generator exists)
    if ($selectedModels.Contains("food")) {
        $foodCalibScript = Join-Path $ScriptDir "SWW_energia_zywnosc\calibration\generate_mod_inputs.ps1"
        if (Test-Path $foodCalibScript) {
            Write-Host "  -> Generating Dynare input modules for SWW_energia_zywnosc..." -ForegroundColor Cyan
            & powershell -ExecutionPolicy Bypass -File $foodCalibScript @calibParams
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Food model calibration generation failed with exit code $LASTEXITCODE."
                exit $LASTEXITCODE
            }
        }
    }

    $elapsedStage2 = ((Get-Date) - $stage2Timer).TotalSeconds
    Write-Host "  [SUCCESS] Stage 2 completed in $($elapsedStage2.ToString('F1')) s." -ForegroundColor Green
    $summaryReport.Add([PSCustomObject]@{
        Stage   = "Calibration Sync (Calibrations.xlsx)"
        Status  = "SUCCESS"
        Elapsed = "$($elapsedStage2.ToString('F1')) s"
    })
} else {
    Write-Host "`n[3/4] Stage 2: Calibration Synchronization SKIPPED (-SkipCalibration)." -ForegroundColor DarkGray
    $summaryReport.Add([PSCustomObject]@{
        Stage   = "Calibration Sync (Calibrations.xlsx)"
        Status  = "SKIPPED"
        Elapsed = "-"
    })
}

# -----------------------------------------------------------------------------
# 5. Stage 3: Model Execution
# -----------------------------------------------------------------------------
Write-Host "`n[4/4] Stage 3: Executing Selected DSGE Models..." -ForegroundColor Yellow

foreach ($model in $selectedModels) {
    $modelTimer = Get-Date

    switch ($model) {
        "classic" {
            Write-Host "`n----------------------------------------------------------" -ForegroundColor Cyan
            Write-Host " MODEL: SWW Klasyczny (Simulation + IRF Plots)" -ForegroundColor Cyan
            Write-Host "----------------------------------------------------------" -ForegroundColor Cyan
            $classicRunner = Join-Path $ScriptDir "SWW_klasyczny\run_steps.ps1"
            $argsList = @("-DynarePath", $DynarePath)
            if ($Interactive) { $argsList += "-Interactive" }
            if ($SavePlots)   { $argsList += "-SavePlots" }

            & powershell -ExecutionPolicy Bypass -File $classicRunner @argsList
            if ($LASTEXITCODE -ne 0) {
                Write-Error "SWW_klasyczny failed with exit code $LASTEXITCODE."
                exit $LASTEXITCODE
            }
            $dur = ((Get-Date) - $modelTimer).TotalSeconds
            $summaryReport.Add([PSCustomObject]@{
                Stage   = "Model: SWW_klasyczny"
                Status  = "SUCCESS"
                Elapsed = "$($dur.ToString('F1')) s"
            })
        }

        "energy" {
            Write-Host "`n----------------------------------------------------------" -ForegroundColor Cyan
            Write-Host " MODEL: SWW Energia w Produkcji (Simulation + Validation)" -ForegroundColor Cyan
            Write-Host "----------------------------------------------------------" -ForegroundColor Cyan
            $energyRunner = Join-Path $ScriptDir "SWW_energia_w_produkcji\run_steps.ps1"
            $argsList = @("-DynarePath", $DynarePath)
            if ($Interactive) { $argsList += "-Interactive" }

            & powershell -ExecutionPolicy Bypass -File $energyRunner @argsList
            if ($LASTEXITCODE -ne 0) {
                Write-Error "SWW_energia_w_produkcji failed with exit code $LASTEXITCODE."
                exit $LASTEXITCODE
            }
            $dur = ((Get-Date) - $modelTimer).TotalSeconds
            $summaryReport.Add([PSCustomObject]@{
                Stage   = "Model: SWW_energia_w_produkcji"
                Status  = "SUCCESS"
                Elapsed = "$($dur.ToString('F1')) s"
            })
        }

        "food" {
            Write-Host "`n----------------------------------------------------------" -ForegroundColor Cyan
            Write-Host " MODEL: SWW Energia i Żywność (Simulation + Validation)" -ForegroundColor Cyan
            Write-Host "----------------------------------------------------------" -ForegroundColor Cyan
            $foodRunner = Join-Path $ScriptDir "SWW_energia_zywnosc\run_steps.ps1"
            $argsList = @("-DynarePath", $DynarePath)
            if ($Interactive) { $argsList += "-Interactive" }

            & powershell -ExecutionPolicy Bypass -File $foodRunner @argsList
            if ($LASTEXITCODE -ne 0) {
                Write-Error "SWW_energia_zywnosc failed with exit code $LASTEXITCODE."
                exit $LASTEXITCODE
            }
            $dur = ((Get-Date) - $modelTimer).TotalSeconds
            $summaryReport.Add([PSCustomObject]@{
                Stage   = "Model: SWW_energia_zywnosc"
                Status  = "SUCCESS"
                Elapsed = "$($dur.ToString('F1')) s"
            })
        }
    }
}

# -----------------------------------------------------------------------------
# 6. Pipeline Summary
# -----------------------------------------------------------------------------
$totalElapsed = ((Get-Date) - $pipelineStartTime).TotalSeconds

Write-Host "`n================================================================================" -ForegroundColor Green
Write-Host "                       PIPELINE EXECUTION SUMMARY                               " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
$summaryReport | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
Write-Host " Total Elapsed Time: $($totalElapsed.ToString('F1')) s" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
