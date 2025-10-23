@echo off
if not defined CONDA_PREFIX set "CONDA_PREFIX=%PREFIX%"
set "PATH=%CONDA_PREFIX%\share\dcm4che\bin;%PATH%"