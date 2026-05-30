[CmdletBinding()]
param(
  [string]$Version = "",
  [string]$DllDir = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($DllDir)) {
  $DllDir = Join-Path $repoRoot "dlls"
}
if ([string]::IsNullOrWhiteSpace($Version)) {
  $Version = (Get-Date -Format "yyyy.MM.dd")
}

if (-not (Test-Path $DllDir)) {
  throw "DLL directory not found: $DllDir"
}

$files = @{}
Get-ChildItem -Path $DllDir -Filter "*.dll" -File | Sort-Object Name | ForEach-Object {
  $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  $files[$_.Name] = [ordered]@{
    sha256 = $hash
    size   = $_.Length
  }
}

$manifest = [ordered]@{
  version    = $Version
  repository = "hqnatx/dll-idols"
  branch     = "main"
  baseUrl    = "https://raw.githubusercontent.com/hqnatx/dll-idols/main/dlls"
  files      = $files
}

$manifestPath = Join-Path $repoRoot "manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host "Wrote $($files.Count) entries to $manifestPath (version $Version)"
