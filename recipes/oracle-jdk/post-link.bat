
@echo off

echo "Installing in %CONDA_PREFIX%" > %PREFIX%\.messages.txt
echo "   CONDA_PREFIX: %CONDA_PREFIX%" > %PREFIX%\.messages.txt
echo "   PREFIX:       %PREFIX%"       > %PREFIX%\.messages.txt
echo "   PKG_NAME:     %PKG_NAME%"     > %PREFIX%\.messages.txt
echo "   PKG_VERSION:  %PKG_VERSION%"  > %PREFIX%\.messages.txt
echo "   PKG_BUILDNUM: %PKG_BUILDNUM%" > %PREFIX%\.messages.txt
:: set | FindStr "PKG" > %PREFIX%\.messages.txt

set "PKG_BIN=%CONDA_PREFIX%\bin"
set "PKG_INC=%CONDA_PREFIX%\include"
set "PKG_JRE=%CONDA_PREFIX%\jre"
set "PKG_JRE_BIN=%CONDA_PREFIX%\jre\bin"
set "PKG_JRE_LIB=%CONDA_PREFIX%\jre\lib"
set "PKG_LIB=%CONDA_PREFIX%\lib"
set "PKG_UUID=%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"

:: should I be using `reg query ` to find the jdk directory path?
set "SRC_DIR=%ProgramFiles%\Java\jdk1.8.0_321"

:: Discovery
SetLocal EnableExtensions EnableDelayedExpansion
if not exist "%SRC_DIR%" (
  echo "The target JDK version has not been installed. %SRC_DIR%" >> "%PREFIX%\.messages.txt"
  echo "see https://www.oracle.com/java/technologies/downloads/#java8-windows" >> "%PREFIX%\.messages.txt"
  exit /B 1
)

echo "Preparing to link *.exe files, from %SRC_DIR%." >> "%PREFIX%\.messages.txt"

set "REVERT_SCRIPT=%CONDA_PREFIX%\conda-link-meta\%PKG_UUID%\pre-unlink-aux.bat"
type nul > "%REVERT_SCRIPT%"

if not exist "%PKG_BIN%" mkdir -p "%PKG_BIN%"
for /R "%SRC_DIR%\bin" %%G in (*.exe) do (
  mklink "%PKG_BIN%\%%~nxG" "%%G" || echo failed linking "%PKG_BIN%\%%~nxG" "%%G" >> "%PREFIX%\.messages.txt"
  echo del "%PKG_BIN%\%%~nxG" >> "%REVERT_SCRIPT%"
)

exit /B 0
