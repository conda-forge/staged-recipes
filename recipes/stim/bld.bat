@echo off
setlocal EnableExtensions

set "INSTALL_DIR=%PREFIX%\bin"
set "MVN_REPOSITORY=%PREFIX%\lib\stim"

mkdir "%INSTALL_DIR%"
mkdir "%MVN_REPOSITORY%"

install_windows.bat /i %INSTALL_DIR% /r %MVN_REPOSITORY%

:: remove hard-coded memory limit
for %%f in ("%INSTALL_DIR%\st-*.bat") do (
  findstr /v "Xmx" %%f > "%INSTALL_DIR%\tmp.txt"
  move /y "%INSTALL_DIR%\tmp.txt" %%f
)

