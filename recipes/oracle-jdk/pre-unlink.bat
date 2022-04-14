
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "REVERT_SCRIPT=%CONDA_PREFIX%\conda-link-meta\%PKG_UUID%\pre-unlink-aux.bat"

if exist "%REVERT_SCRIPT%" do (
  start %comspec% /c "%REVERT_SCRIPT%"
  del "%REVERT_SCRIPT%"
)
