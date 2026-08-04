@echo off
set "CONDA_SWIFT_BIN="
for /d %%D in ("%CONDA_PREFIX%\Toolchains\*") do (
  if exist "%%~fD\usr\bin\swiftc.exe" set "CONDA_SWIFT_BIN=%%~fD\usr\bin"
)
if not defined CONDA_SWIFT_BIN exit /b 1
set "SWIFT=%CONDA_SWIFT_BIN%\swiftc.exe"
set "SWIFTC=%SWIFT%"
set "SWIFT_EXEC=%SWIFT%"
set "CONDA_SWIFT_COMPILER=1"
