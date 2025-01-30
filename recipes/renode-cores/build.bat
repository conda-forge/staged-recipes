@echo off

setlocal EnableDelayedExpansion

rem Update the submodule to the latest commit CMakeLists.txt
copy "%RECIPE_DIR%\patches\Cores-CMakeLists.txt" "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\CMakeLists.txt"
copy "%RECIPE_DIR%\patches\tlib-CMakeLists.txt" "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\tlib\CMakeLists.txt"
if %errorlevel% neq 0 exit /b  %errorlevel%

powershell -ExecutionPolicy Bypass -File "%RECIPE_DIR%\helpers\renode_build_with_cmake.ps1" --tlib-only --net --no-gui
if %errorlevel% neq 0 exit /b  %errorlevel%

rem Install procedure into a conda path that renode-cli can retrieve
set "CONFIGURATION=Release"
set "CORES_PATH=%SRC_DIR%\src\Infrastructure\src\Emulator\Cores"
set "CORES_BIN_PATH=%CORES_PATH%\bin\%CONFIGURATION%"

mkdir "%PREFIX%\Library\lib\%PKG_NAME%"
icacls "%PREFIX%\Library\lib\%PKG_NAME%" /grant Users:(OI)(CI)F /T
robocopy "%CORES_BIN_PATH%\lib" "%PREFIX%\Library\lib\%PKG_NAME%" /E /COPY:DATSO

:: Setting conda host environment variables
if not exist "%PREFIX%\etc\conda\activate.d\" mkdir "%PREFIX%\etc\conda\activate.d\"
if not exist "%PREFIX%\etc\conda\deactivate.d\" mkdir "%PREFIX%\etc\conda\deactivate.d\"

copy "%RECIPE_DIR%\scripts\activate.bat" "%PREFIX%\etc\conda\activate.d\%PKG_NAME%-activate.bat" > nul
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
copy "%RECIPE_DIR%\scripts\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%-deactivate.bat" > nul
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
