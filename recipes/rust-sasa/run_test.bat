@echo off
setlocal enabledelayedexpansion

if %errorlevel% neq 0 exit /b %errorlevel%

rust-sasa tests\data\pdbs\example.cif out.json

if not exist out.json (
  echo File out.json does not exist
  exit /b 1
)

echo DEBUG: out.json contents:
type out.json
echo DEBUG: End of contents

powershell -Command "& { $output = Get-Content out.json -Raw; $json = $output | ConvertFrom-Json; if ([Math]::Abs($json.value - 220.10417) -gt 0.00001) { exit 1 } else { Write-Host 'Value OK' } }"

if %errorlevel% neq 0 (
  echo Expected string '!expected!' not found in output
  exit /b 1
)

echo Test passed!
