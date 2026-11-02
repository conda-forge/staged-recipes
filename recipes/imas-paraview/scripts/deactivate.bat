@echo off
set "_IMAS_PY=%CONDA_PREFIX%\python.exe"
set "_IMAS_HELPER=%CONDA_PREFIX%\etc\conda\imas-paraview-pvpath.py"
if not exist "%_IMAS_HELPER%" goto :imas_end
"%_IMAS_PY%" "%_IMAS_HELPER%" owned >nul 2>nul
if errorlevel 1 goto :imas_end
set "_IMAS_KEY="
for /f "delims=" %%V in ('""%_IMAS_PY%" "%_IMAS_HELPER%" key"') do set "_IMAS_KEY=%%V"
if not defined _IMAS_KEY goto :imas_end
rem Compute the new value before changing PV_PLUGIN_PATH.
set "_IMAS_NEW="
for /f "delims=" %%V in ('""%_IMAS_PY%" "%_IMAS_HELPER%" remove"') do set "_IMAS_NEW=%%V"
set "PV_PLUGIN_PATH=%_IMAS_NEW%"
set "%_IMAS_KEY%="
:imas_end
set "_IMAS_KEY="
set "_IMAS_NEW="
set "_IMAS_PY="
set "_IMAS_HELPER="
