@echo off
setlocal
set "SWIFT_LAUNCHER_BIN=%CONDA_SWIFT_BIN%"
if not defined SWIFT_LAUNCHER_BIN (
  for /d %%D in ("%CONDA_PREFIX%\Toolchains\*") do (
    if exist "%%~fD\usr\bin\swiftc.exe" set "SWIFT_LAUNCHER_BIN=%%~fD\usr\bin"
  )
)
if not defined SWIFT_LAUNCHER_BIN exit /b 1
"%SWIFT_LAUNCHER_BIN%\%~n0.exe" %*
