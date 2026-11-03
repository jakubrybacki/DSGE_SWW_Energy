<#
.SYNOPSIS
    Executes the classic SWW model pipeline: step_1_run_model.m and step_2_plot_irf.m.

.DESCRIPTION
    Runs MATLAB with Dynare to simulate the model (step 1) and plot impulse response functions (step 2).
    By default runs in non-interactive batch mode. Use -Interactive to open the MATLAB GUI,
    or -SavePlots to export generated figures as PNG images.

.PARAMETER DynarePath
    Path to Dynare MATLAB directory. Defaults to C:\dynare\7.1\matlab (or auto-detected under C:\dynare).

.PARAMETER Interactive
    Switch to run MATLAB interactively (opens MATLAB GUI, keeping plots open).

.PARAMETER SavePlots
    Switch to save all generated figures as PNGs in the 'figures' subfolder.

.EXAMPLE
    .\run_steps.ps1
    Runs both steps in batch mode in the console.

.EXAMPLE
    .\run_steps.ps1 -SavePlots
    Runs both steps and exports all 18 figures to the 'figures' directory.

.EXAMPLE
    .\run_steps.ps1 -Interactive
    Launches MATLAB GUI and displays figures interactively.
#>
[CmdletBinding()]
param(
    [string]$DynarePath = "",
    [switch]$Interactive,
    [switch]$SavePlots
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " SWW Classical Model: Running step_1 and step_2" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Locate MATLAB executable
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

# Normalize paths for MATLAB (use forward slashes)
$matlabDynarePath = $DynarePath.Replace("\", "/")
$matlabModelDir   = $ScriptDir.Replace("\", "/")

# 3. Construct MATLAB commands
$commands = @(
    "addpath('$matlabDynarePath');",
    "cd('$matlabModelDir');",
    "fprintf('\n[STEP 1/2] Simulating SWW classic model...\n');",
    "step_1_run_model;",
    "fprintf('\n[STEP 2/2] Generating IRF plots...\n');",
    "step_2_plot_irf;"
)

if ($SavePlots) {
    $saveCmd = @'
figs = findall(groot, 'Type', 'figure');
if ~isempty(figs)
    if ~exist('figures', 'dir'), mkdir('figures'); end
    for k = 1:numel(figs)
        num = figs(k).Number;
        t = '';
        ax = findall(figs(k), 'Type', 'axes');
        if ~isempty(ax) && ~isempty(ax(1).Title.String)
            t = regexprep(ax(1).Title.String, '[^\w]', '_');
        end
        fname = sprintf('figures/Figure_%02d_%s.png', num, t);
        fname = regexprep(fname, '_+\.png$', '.png');
        exportgraphics(figs(k), fname, 'Resolution', 150);
    end
    fprintf('\n[OK] Saved %d figures to figures/\n', numel(figs));
end
'@
    $commands += $saveCmd
}

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
