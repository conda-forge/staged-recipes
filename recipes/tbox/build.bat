@echo off
set REMOVE_LIB_PREFIX=1

if not exist "%PREFIX%\Library\lib" mkdir "%PREFIX%\Library\lib"
if not exist "%PREFIX%\Library\include" mkdir "%PREFIX%\Library\include"
if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"

call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" win.sh

if %ERRORLEVEL% neq 0 exit 1
