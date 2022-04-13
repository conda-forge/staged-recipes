
@echo off

echo "Installing in %PREFIX%" > %PREFIX%\.messages.txt
:: set | FindStr "PKG" > %PREFIX%\.messages.txt

set "PKG_BIN=%PREFIX%\bin"
set "PKG_INC=%PREFIX%\include"
set "PKG_JRE=%PREFIX%\jre"
set "PKG_JRE_BIN=%PREFIX%\jre\bin"
set "PKG_JRE_LIB=%PREFIX%\jre\lib"
set "PKG_LIB=%PREFIX%\lib"

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

if not exist "%PKG_BIN%" mkdir -p "%PKG_BIN%"
for /R "%SRC_DIR%\bin" %%G in (*.exe) do (
  mklink "%PKG_BIN%\%%~nxG" "%%G" || echo failed linking "%PKG_BIN%\%%~nxG" "%%G" >> "%PREFIX%\.messages.txt"
)

exit /B 0
