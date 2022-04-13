
@echo off

echo "TEST_VAR is set to :%TEST_VAR%:" >> %PREFIX%\.messages.txt
if "%TEST_VAR%"=="1" (
    echo "Success: TEST_VAR is set correctly" >> %PREFIX%\.messages.txt
    exit 0
)
echo "ERROR: TEST_VAR is not set or set incorrectly" >> %PREFIX%\.messages.txt

set PKG_BIN=%PREFIX%\bin
set PKG_INC=%PREFIX%\include
set PKG_JRE=%PREFIX%\jre
set PKG_JRE_BIN=%PREFIX%\jre\bin
set PKG_JRE_LIB=%PREFIX%\jre\lib
set PKG_LIB=%PREFIX%\lib

set SRC_DIR="%ProgramFiles%\Java\jdk1.8.0_321"

:: Setup
:: https://www.oracle.com/java/technologies/downloads/#java8-windows

:: Discover
SetLocal EnableExtensions EnableDelayedExpansion
if not exist %SRC_DIR% (
  echo The target JDK version has not been installed. >> "%PREFIX%\.messages.txt"
  exit /B 1
)

for /R "%SRC_DIR%\bin" %%G in (*.exe) do mklink %%G "%PKG_BIN%\%%~nxG"
