@echo off
setlocal EnableExtensions

set "INSTALL_DIR=%PREFIX%\bin"
set "MVN_REPOSITORY=%PREFIX%\lib\stim"

mkdir "%INSTALL_DIR%"
mkdir "%MVN_REPOSITORY%"

install_windows.bat /i %INSTALL_DIR% /r %MVN_REPOSITORY%
