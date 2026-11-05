@echo off
setlocal
rem Installed as PREFIX\Scripts\<tool>.bat; the toolchain is kept privately in
rem PREFIX\Library\swift so its bundled LLVM tools stay off PATH.
for %%I in ("%~dp0..") do set "SWIFT_LAUNCHER_PREFIX=%%~fI"
set "SWIFT_LAUNCHER_BIN="
for /d %%D in ("%SWIFT_LAUNCHER_PREFIX%\Library\swift\Toolchains\*") do (
  if exist "%%~fD\usr\bin\swiftc.exe" set "SWIFT_LAUNCHER_BIN=%%~fD\usr\bin"
)
if not defined SWIFT_LAUNCHER_BIN (
  echo %~n0: Swift toolchain not found in %SWIFT_LAUNCHER_PREFIX%\Library\swift 1>&2
  exit /b 1
)
rem Work without the swift_win-64 activation package as well.
if not defined SDKROOT (
  for /d %%D in ("%SWIFT_LAUNCHER_PREFIX%\Library\swift\Platforms\*") do (
    if exist "%%~fD\Windows.platform\Developer\SDKs\Windows.sdk" set "SDKROOT=%%~fD\Windows.platform\Developer\SDKs\Windows.sdk"
  )
)
set "PATH=%SWIFT_LAUNCHER_PREFIX%\Library\bin;%PATH%"
"%SWIFT_LAUNCHER_BIN%\%~n0.exe" %*
exit /b %ERRORLEVEL%
