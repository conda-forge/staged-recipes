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

endlocal
