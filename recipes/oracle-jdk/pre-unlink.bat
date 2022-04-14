
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "REVERT_SCRIPT=%CONDA_PREFIX%\conda-link-meta\%PKG_UUID%\pre-unlink-aux.bat"

source "%REVERT_SCRIPT%"

