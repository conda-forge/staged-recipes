@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX="%LIBRARY_PREFIX:\=/%"
set BUILD_PREFIX="%BUILD_PREFIX:\=/%"
set SRC_DIR="%SRC_DIR:\=/%"

:: Once DLLs are working, we should install the non-devel packages using
::     cmake --install .b --component google_cloud_cpp_runtime
:: and the devel packages using
::     cmake --install .b --component google_cloud_cpp_development

if [%PKG_NAME%] == [libgoogle-cloud-bigquery-devel] (
  cmake --install build
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-bigquery] (
  @REM TODO: fix when DLL support comes along
) else (
  @ECHO Unknown package name %PKG_NAME%
  exit 1
)
