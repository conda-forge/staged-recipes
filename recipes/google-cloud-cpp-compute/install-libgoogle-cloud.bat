@echo on

:: Once DLLs are working, we should install the non-devel packages using
::     cmake --install .b --component google_cloud_cpp_runtime
:: and the devel packages using
::     cmake --install .b --component google_cloud_cpp_development

if [%PKG_NAME%] == [libgoogle-cloud-compute-devel] (
  cmake --install build
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-compute] (
  @REM TODO: fix when DLL support comes along
) else (
  @ECHO Unknown package name %PKG_NAME%
  exit 1
)
