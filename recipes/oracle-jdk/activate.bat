
@echo off

set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "MESO_DIR=%CONDA_PREFIX%\conda-meso\%PKG_UUID%"
if not exist "%MESO_DIR%" mkdir "%MESO_DIR%"

set "DISCOVER_SCRIPT=%MESO_DIR%\discovery.bat"
if exist "%DISCOVER_SCRIPT%" call "%DISCOVER_SCRIPT%"

set "REVERT_SCRIPT=%MESO_DIR%\deactivate-aux.bat"
type nul > "%REVERT_SCRIPT%"
echo Writing revert-script to %REVERT_SCRIPT%

echo set "JAVA_HOME=%JAVA_HOME%" >> "%REVERT_SCRIPT%"
set "JAVA_HOME=%ORACLE_JDK_DIR%"
