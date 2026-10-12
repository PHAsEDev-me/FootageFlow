$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$mainCpp = Join-Path $root 'windows\runner\main.cpp'
if (!(Test-Path $mainCpp)) { throw 'windows/runner/main.cpp was not found. Put windows_patch inside the FootageFlow project first.' }
$m = Get-Content $mainCpp -Raw
$m = $m.Replace('L"footage_collector"', 'L"FootageFlow"')
$m = $m.Replace('L"Footage Collector"', 'L"FootageFlow"')
Set-Content -Path $mainCpp -Value $m -Encoding UTF8
Write-Host 'Windows title updated to FootageFlow.' -ForegroundColor Green
