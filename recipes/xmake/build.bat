@echo off
set REMOVE_LIB_PREFIX=1

cd /D "%SRC_DIR%"

if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"
if not exist "%PREFIX%\Library\include" mkdir "%PREFIX%\Library\include"
if not exist "%PREFIX%\Library\lib" mkdir "%PREFIX%\Library\lib"

call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" win.sh
if %ERRORLEVEL% neq 0 exit /b 1

copy /Y "%RECIPE_DIR%\xrepo.bat" "%PREFIX%\Library\bin\xrepo.bat"
if %ERRORLEVEL% neq 0 exit /b 1
