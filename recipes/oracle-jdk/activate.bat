
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "REVERT_DIR=%CONDA_PREFIX%\conda-meso\%PKG_UUID%"
if not exist "%REVERT_DIR%" mkdir "%REVERT_DIR%"

set "REVERT_SCRIPT=%REVERT_DIR%\deactivate-aux.bat"
type nul > "%REVERT_SCRIPT%"
echo Writing revert-script to %REVERT_SCRIPT%

echo set "JAVA_HOME=%JAVA_HOME%" >> "%REVERT_SCRIPT%"
set "JAVA_HOME=%ProgramFiles%\Java\jdk1.8.0_321"
