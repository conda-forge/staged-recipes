
@echo off

echo "PREFIX: %PREFIX%" > %PREFIX%\.messages.txt
set >> %PREFIX%\.messages.txt

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
  echo "The target JDK version has not been installed. %SRC_DIR%" >> "%PREFIX%\.messages.txt"
  exit /B 1
)

echo "Preparing to link *.exe files, from %SRC_DIR%." >> "%PREFIX%\.messages.txt"

for /R "%SRC_DIR%\bin" %%G in (*.exe) do (
  echo "linking %%~nxG files." >> "%PREFIX%\.messages.txt"
  mklink "%%G" "%PKG_BIN%\%%~nxG"
)

