@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX="%LIBRARY_PREFIX:\=/%"
set BUILD_PREFIX="%BUILD_PREFIX:\=/%"
set SRC_DIR="%SRC_DIR:\=/%"

:: Once DLLs are working, we should install the non-devel packages using
::     cmake --install .build/%FEATURE% --component google_cloud_cpp_runtime
:: and the devel packages using
::     cmake --install .build/%FEATURE% --component google_cloud_cpp_development

set FEATURE=%PKG_NAME:libgoogle-cloud-=%
set FEATURE=%FEATURE:-devel=%

if not [%PKG_NAME:-devel=%] == [%PKG_NAME%] (
  cmake --install build/%FEATURE%
  if %ERRORLEVEL% neq 0 exit 1
) else if not [%PKG_NAME:libgoogle-cloud-=%] == [%PKG_NAME%] (
  @REM TODO: fix when DLL support comes along
) else (
  @ECHO Unknown package name %PKG_NAME%
  exit 1
)
