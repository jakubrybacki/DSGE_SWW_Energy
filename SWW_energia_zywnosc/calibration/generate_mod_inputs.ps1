param([string]$Country='EA20',[switch]$Check,[string]$PythonExecutable='')
$ErrorActionPreference='Stop'
if(!$PythonExecutable){
  $bundled=Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
  if(Test-Path -LiteralPath $bundled){$PythonExecutable=$bundled}
  else {$PythonExecutable=(Get-Command python -ErrorAction Stop).Source}
}
$script=Join-Path $PSScriptRoot 'generate_mod_inputs.py'
$arguments=@($script,'--country',$Country)
if($Check){$arguments+='--check'}
& $PythonExecutable @arguments
if($LASTEXITCODE -ne 0){throw "Food calibration generator failed ($LASTEXITCODE)."}
