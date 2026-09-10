@echo off
set "CONDA_SWIFT_BIN="
for /d %%D in ("%CONDA_PREFIX%\Toolchains\*") do (
  if exist "%%~fD\usr\bin\swiftc.exe" set "CONDA_SWIFT_BIN=%%~fD\usr\bin"
)
if not defined CONDA_SWIFT_BIN exit /b 1
set "CONDA_SWIFT_SDKROOT_BACKUP=%SDKROOT%"
set "CONDA_SWIFT_SDKROOT_SET=1"
set "SDKROOT="
for /d %%D in ("%CONDA_PREFIX%\Platforms\*") do (
  if exist "%%~fD\Windows.platform\Developer\SDKs\Windows.sdk" set "SDKROOT=%%~fD\Windows.platform\Developer\SDKs\Windows.sdk"
)
if not defined SDKROOT exit /b 1
set "SWIFT=%CONDA_SWIFT_BIN%\swiftc.exe"
set "SWIFTC=%SWIFT%"
set "SWIFT_EXEC=%SWIFT%"
set "CONDA_SWIFT_COMPILER=1"
