
@echo off

SetLocal EnableExtensions EnableDelayedExpansion

(
    echo Installing in %CONDA_PREFIX%
    echo    CONDA_PREFIX: %CONDA_PREFIX%
    echo    PKG_NAME:     %PKG_NAME%
    echo    PKG_VERSION:  %PKG_VERSION%
    echo    PKG_BUILDNUM: %PKG_BUILDNUM%
) > "%CONDA_PREFIX%\.messages.txt"

set "PKG_BIN=%CONDA_PREFIX%\bin"
set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"

set "CONDA_MESO=%CONDA_PREFIX%\conda-meso\%PKG_UUID%"
if not exist "%CONDA_MESO%" mkdir "%CONDA_MESO%"

rem  Discovery
rem  should I be using `reg query ` to find the jdk directory path?
set WIP=0
for /D %%G in ("%ProgramFiles%\Java\jdk1.8.0_*") do (
  for /F "tokens=2,3,4 delims=-._" %%H in ("%%~nxG") do (
    if %%J GTR !WIP! (
      set WIP=%%J
      set "ORACLE_JDK_DIR=%%G"
    )
  )
)

if not exist "%ORACLE_JDK_DIR%" (
    (
      echo The target JDK version has not been installed. %ORACLE_JDK_DIR%
      echo see https://www.oracle.com/java/technologies/downloads/#java8-windows
      echo  jdk-8u321-windows-x64.exe
    )  >> "%CONDA_PREFIX%\.messages.txt"
    exit /B 0
)
set "DISCOVERY_SCRIPT=%CONDA_MESO%\discovery.bat"
echo Writing pkg-script to %DISCOVERY_SCRIPT% >> "%CONDA_PREFIX%\.messages.txt"
echo set "ORACLE_JDK_DIR=%ORACLE_JDK_DIR%" > "%DISCOVERY_SCRIPT%"

echo Preparing to link *.exe files, from %ORACLE_JDK_DIR%. >> "%CONDA_PREFIX%\.messages.txt"

set "UNLINK_SCRIPT=%CONDA_MESO%\unlink-aux.bat"
echo Writing revert-script to %UNLINK_SCRIPT% >> "%CONDA_PREFIX%\.messages.txt"
type nul > "%UNLINK_SCRIPT%"

if not exist "%PKG_BIN%" mkdir "%PKG_BIN%"
for /R "%ORACLE_JDK_DIR%\bin" %%G in (*.exe) do (
  for %%H in (%PKG_BIN%\%%~nxG) do (
      if not exist "%%H" (
        mklink "%%H" "%%G" || echo failed linking "%%H" "%%G" >> "%CONDA_PREFIX%\.messages.txt"
      )
      echo del "%%H" >> "%UNLINK_SCRIPT%"
  )
)
echo Successfully linked *.exe files. >> "%CONDA_PREFIX%\.messages.txt"

exit /B 0
