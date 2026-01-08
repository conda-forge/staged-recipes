@echo off
setlocal enabledelayedexpansion

if %errorlevel% neq 0 exit /b %errorlevel%

rust-sasa tests\data\pdbs\example.cif out.json

if not exist out.json (
  echo File out.json does not exist
  exit /b 1
)

for /f "delims=" %%i in (out.json) do set "output=%%i"

set "expected="value":220.10417,"name":"MET","is_polar":false"

echo !output! | findstr /c:"!expected!" >nul
if %errorlevel% neq 0 (
  echo Expected string '!expected!' not found in output
  exit /b 1
)

echo Test passed!
