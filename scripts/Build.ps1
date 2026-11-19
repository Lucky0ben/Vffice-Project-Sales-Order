[CmdletBinding()]
param([string]$CompilerPath, [string]$SymbolsPath, [switch]$IncludeTests)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (!$SymbolsPath) { $SymbolsPath = Join-Path $root 'app/.alpackages' }
if (!(Test-Path $SymbolsPath)) { throw "Download symbols in VS Code first. Missing $SymbolsPath" }
if (!(Get-ChildItem $SymbolsPath -Filter '*.app')) { throw 'No symbol packages were found.' }
if (!$CompilerPath) {
  $paths = @(Get-ChildItem (Join-Path $env:USERPROFILE '.vscode/extensions/ms-dynamics-smb.al-*/bin/win32/alc.exe') -ErrorAction SilentlyContinue | Sort-Object FullName -Descending)
  if (!$paths.Count) { throw 'Pass -CompilerPath pointing to alc.exe (or alc.dll with dotnet installed).' }
  $CompilerPath = $paths[0].FullName
}
$artifacts = Join-Path $root 'artifacts'
New-Item -ItemType Directory -Force $artifacts | Out-Null
function Compile([string]$project, [string]$output) {
  $args = @("/project:$project", "/packagecachepath:$SymbolsPath", "/out:$output")
  if ($CompilerPath.EndsWith('.dll')) { & dotnet $CompilerPath @args } else { & $CompilerPath @args }
  if ($LASTEXITCODE -ne 0) { throw "AL compiler failed ($LASTEXITCODE)." }
  if (!(Test-Path $output)) { throw 'Compiler returned without creating the package.' }
}
$app = Join-Path $artifacts 'Vffice_ProjectMaterials_1.3.0.0.app'
Compile (Join-Path $root 'app') $app
if ($IncludeTests) {
  Copy-Item $app $SymbolsPath -Force
  Compile (Join-Path $root 'tests') (Join-Path $artifacts 'Vffice_ProjectMaterialsTests_1.3.0.0.app')
}
Get-FileHash (Join-Path $artifacts '*.app') -Algorithm SHA256
