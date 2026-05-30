# Copies dll-idols files into %AppData%\idols Link\ for AV-hardened idols Link builds.
param(
  [string]$DllRepoRoot = "",
  [string]$TargetRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DllRepoRoot)) {
  $DllRepoRoot = Split-Path -Parent $PSScriptRoot
}
if ([string]::IsNullOrWhiteSpace($TargetRoot)) {
  $TargetRoot = Join-Path $env:APPDATA "idols Link"
}

$dllSource = Join-Path $DllRepoRoot "dlls"
$toolsSource = Join-Path $DllRepoRoot "tools"
$dllTarget = Join-Path $TargetRoot "dlls"
$toolsTarget = Join-Path $TargetRoot "tools"

if (-not (Test-Path -LiteralPath $dllSource)) {
  throw "DLL source folder not found: $dllSource"
}

New-Item -ItemType Directory -Force -Path $dllTarget | Out-Null
New-Item -ItemType Directory -Force -Path $toolsTarget | Out-Null

Get-ChildItem -LiteralPath $dllSource -Filter "*.dll" -File | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dllTarget $_.Name) -Force
  Write-Host "Copied $($_.Name)"
}

$injectHelper = Join-Path $toolsSource "idols_inject_helper.exe"
if (Test-Path -LiteralPath $injectHelper) {
  Copy-Item -LiteralPath $injectHelper -Destination (Join-Path $toolsTarget "idols_inject_helper.exe") -Force
  Write-Host "Copied idols_inject_helper.exe"
}

Write-Host "Done. Files are in $TargetRoot"
