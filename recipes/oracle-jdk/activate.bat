

set "CONDA_MESO=%CONDA_PREFIX%\conda-meso\%PKG_UUID%"
if not exist "%CONDA_MESO%" mkdir "%CONDA_MESO%"

set "DISCOVER_SCRIPT=%CONDA_MESO%\discovery.bat"
if exist "%DISCOVER_SCRIPT%" call "%DISCOVER_SCRIPT%"

set "DEACTIVATE_SCRIPT=%CONDA_MESO%\deactivate-aux.bat"
echo @echo off > "%DEACTIVATE_SCRIPT%"
echo Writing revert-script to %DEACTIVATE_SCRIPT%


echo rem "JDK8_HOME=%ORACLE_JDK_DIR%" >> "%DEACTIVATE_SCRIPT%"
echo set "JDK8_HOME=%JDK8_HOME%" >> "%DEACTIVATE_SCRIPT%"
set "JDK8_HOME=%ORACLE_JDK_DIR%"

echo rem "JAVA_HOME=%ORACLE_JDK_DIR%" >> "%DEACTIVATE_SCRIPT%"
echo set "JAVA_HOME=%JAVA_HOME%" >> "%DEACTIVATE_SCRIPT%"
set "JAVA_HOME=%ORACLE_JDK_DIR%"
