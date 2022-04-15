
@echo off

echo "Installing in %CONDA_PREFIX%" > "%CONDA_PREFIX%\.messages.txt"
echo "   CONDA_PREFIX: %CONDA_PREFIX%" >> "%CONDA_PREFIX%\.messages.txt"
echo "   PKG_NAME:     %PKG_NAME%"     >> "%CONDA_PREFIX%\.messages.txt"
echo "   PKG_VERSION:  %PKG_VERSION%"  >> "%CONDA_PREFIX%\.messages.txt"
echo "   PKG_BUILDNUM: %PKG_BUILDNUM%" >> "%CONDA_PREFIX%\.messages.txt"
:: set | FindStr "PKG" >> "%CONDA_PREFIX%\.messages.txt"

set "PKG_BIN=%CONDA_PREFIX%\bin"
set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"

:: should I be using `reg query ` to find the jdk directory path?
set "ORACLE_JDK_DIR=%ProgramFiles%\Java\jdk1.8.0_321"

:: Discovery
SetLocal EnableExtensions EnableDelayedExpansion
if not exist "%ORACLE_JDK_DIR%" (
  echo "The target JDK version has not been installed. %ORACLE_JDK_DIR%" >> "%CONDA_PREFIX%\.messages.txt"
  echo "see https://www.oracle.com/java/technologies/downloads/#java8-windows" >> "%CONDA_PREFIX%\.messages.txt"
  echo " jdk-8u321-windows-x64.exe "  >> "%CONDA_PREFIX%\.messages.txt"
  exit /B 1
)

echo Preparing to link *.exe files, from %ORACLE_JDK_DIR%. >> "%CONDA_PREFIX%\.messages.txt"

set "REVERT_DIR=%CONDA_PREFIX%\conda-meso\%PKG_UUID%"
if not exist "%REVERT_DIR%" mkdir "%REVERT_DIR%"

set "REVERT_SCRIPT=%REVERT_DIR%\pre-unlink-aux.bat"
echo Writing revert-script to %REVERT_SCRIPT% >> "%CONDA_PREFIX%\.messages.txt"
type nul > "%REVERT_SCRIPT%"

if not exist "%PKG_BIN%" mkdir "%PKG_BIN%"
for /R "%ORACLE_JDK_DIR%\bin" %%G in (*.exe) do (
  if not exist "%PKG_BIN%\%%~nxG" (
    mklink "%PKG_BIN%\%%~nxG" "%%G" || echo failed linking "%PKG_BIN%\%%~nxG" "%%G" >> "%CONDA_PREFIX%\.messages.txt"
  )
  echo del "%PKG_BIN%\%%~nxG" >> "%REVERT_SCRIPT%"
)
echo Successfully linked *.exe files. >> "%CONDA_PREFIX%\.messages.txt"

exit /B 0
