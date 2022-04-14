
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "REVERT_SCRIPT=%CONDA_PREFIX%\conda-activate-meta\%PKG_UUID%\deactivate-aux.bat"

type nul > "%REVERT_SCRIPT%"
echo set "JAVA_HOME=%JAVA_HOME%" >> "%REVERT_SCRIPT%"

set "JAVA_HOME=%ProgramFiles%\Java\jdk1.8.0_321"
