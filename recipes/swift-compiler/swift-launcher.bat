@echo off
setlocal
set "SWIFT_LAUNCHER_BIN=%CONDA_SWIFT_BIN%"
if not defined SWIFT_LAUNCHER_BIN (
  for /d %%D in ("%CONDA_PREFIX%\Toolchains\*\usr\bin") do set "SWIFT_LAUNCHER_BIN=%%~fD"
)
if not defined SWIFT_LAUNCHER_BIN exit /b 1
"%SWIFT_LAUNCHER_BIN%\%~n0.exe" %*
