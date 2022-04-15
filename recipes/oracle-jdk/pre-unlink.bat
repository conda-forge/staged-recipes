
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "REVERT_SCRIPT=%CONDA_PREFIX%\conda-meso\%PKG_UUID%\pre-unlink-aux.bat"

if exist "%REVERT_SCRIPT%" do (
  call "%REVERT_SCRIPT%"
  del "%REVERT_SCRIPT%"
)
