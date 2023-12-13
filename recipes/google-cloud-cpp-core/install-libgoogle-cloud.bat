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

if [%PKG_NAME%] == [libgoogle-cloud] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-devel] (
  REM cmake --install .build/common --component google_cloud_cpp_development
  cmake --install .build/common
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-bigtable] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-bigtable-devel] (
  cmake --install .build/bigtable
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-oauth2] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-oauth2-devel] (
  cmake --install .build/oauth2
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-spanner] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-spanner-devel] (
  cmake --install .build/spanner
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-storage] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-storage-devel] (
  cmake --install .build/storage
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-pubsub] (
  REM TODO: fix when DLL support comes along
) else if [%PKG_NAME%] == [libgoogle-cloud-pubsub-devel] (
  cmake --install .build/pubsub
  if %ERRORLEVEL% neq 0 exit 1
) else if [%PKG_NAME%] == [libgoogle-cloud-iam] (
  REM Nothing to do, installed by pubsub
) else if [%PKG_NAME%] == [libgoogle-cloud-iam-devel] (
  REM Nothing to do, installed by pubsub
) else if [%PKG_NAME%] == [libgoogle-cloud-policytroubleshooter] (
  REM Nothing to do, installed by pubsub
) else if [%PKG_NAME%] == [libgoogle-cloud-policytroubleshooter-devel] (
  REM Nothing to do, installed by pubsub
)
