set "_LIB=%LIB%"
set "_CPATH=%CPATH%"

if "%CONDA_PREFIX%"=="" set "LIB=%LIB%;%PREFIX%\Library\lib"
if "%CONDA_PREFIX%"=="" set "CPATH=%CPATH%;%PREFIX%\Library\include"

if not "%CONDA_PREFIX%"=="" set "LIB=%LIB%;%CONDA_PREFIX%\Library\lib"
if not "%CONDA_PREFIX%"=="" set "CPATH=%CPATH%;%CONDA_PREFIX%\Library\include"
