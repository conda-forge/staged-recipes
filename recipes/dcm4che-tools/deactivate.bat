@echo off
if not defined CONDA_PREFIX set "CONDA_PREFIX=%PREFIX%"
set "DCM4CHE_BIN=%CONDA_PREFIX%\share\dcm4che\bin"

:: remove occurrences with trailing semicolon (start or middle)
set "PATH=%PATH:%DCM4CHE_BIN%;=%"
:: remove occurrence without trailing semicolon (end)
set "PATH=%PATH:%DCM4CHE_BIN%=%"

:: strip a leading semicolon if it remains
if "%PATH:~0,1%"==";" set "PATH=%PATH:~1%"
