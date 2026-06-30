@echo off
set REMOVE_LIB_PREFIX=1

cd /D "%SRC_DIR%"

"%BUILD_PREFIX%\Library\usr\bin\patch.exe" -p1 -i "%RECIPE_DIR%\0001-use-system-lua-lz4-and-tbox.patch"
if %ERRORLEVEL% neq 0 exit /b 1

"%BUILD_PREFIX%\Library\usr\bin\patch.exe" -p1 -i "%RECIPE_DIR%\0002-support-conda-clang-on-windows.patch"
if %ERRORLEVEL% neq 0 exit /b 1

if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"
if not exist "%PREFIX%\Library\include" mkdir "%PREFIX%\Library\include"
if not exist "%PREFIX%\Library\lib" mkdir "%PREFIX%\Library\lib"

call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" win.sh
if %ERRORLEVEL% neq 0 exit /b 1

copy /Y "%RECIPE_DIR%\xrepo.bat" "%PREFIX%\Library\bin\xrepo.bat"
if %ERRORLEVEL% neq 0 exit /b 1
