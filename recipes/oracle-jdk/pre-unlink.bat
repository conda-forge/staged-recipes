
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "UNLINK_SCRIPT=%CONDA_PREFIX%\conda-meso\%PKG_UUID%\pre-unlink-aux.bat"

if exist "%UNLINK_SCRIPT%" do (
  call "%UNLINK_SCRIPT%"
  del "%UNLINK_SCRIPT%"
)
