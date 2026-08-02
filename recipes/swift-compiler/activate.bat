@echo off
set "CONDA_SWIFT_BIN="
for /d %%D in ("%CONDA_PREFIX%\Toolchains\*\usr\bin") do set "CONDA_SWIFT_BIN=%%~fD"
if not defined CONDA_SWIFT_BIN exit /b 1
set "PATH=%CONDA_SWIFT_BIN%;%PATH%"
set "SWIFT=%CONDA_SWIFT_BIN%\swiftc.exe"
set "SWIFTC=%SWIFT%"
set "SWIFT_EXEC=%SWIFT%"
set "CONDA_SWIFT_COMPILER=1"
