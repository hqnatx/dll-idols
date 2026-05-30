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

$tools = @{}
$toolsDir = Join-Path $repoRoot "tools"
$injectHelper = Join-Path $toolsDir "idols_inject_helper.exe"
if (Test-Path -LiteralPath $injectHelper) {
  $helperHash = (Get-FileHash -LiteralPath $injectHelper -Algorithm SHA256).Hash.ToLowerInvariant()
  $tools["idols_inject_helper.exe"] = [ordered]@{
    sha256 = $helperHash
    size   = (Get-Item -LiteralPath $injectHelper).Length
  }
}

$manifest = [ordered]@{
  version    = $Version
  repository = "hqnatx/dll-idols"
  branch     = "main"
  baseUrl    = "https://raw.githubusercontent.com/hqnatx/dll-idols/main/dlls"
  files      = $files
}

if ($tools.Count -gt 0) {
  $manifest.tools = $tools
}

$manifestPath = Join-Path $repoRoot "manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host "Wrote $($files.Count) entries to $manifestPath (version $Version)"
