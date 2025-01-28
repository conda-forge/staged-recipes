@echo off

setlocal EnableDelayedExpansion

rem Update the submodule to the latest commit CMakeLists.txt
copy "%RECIPE_DIR%\patches\Cores-CMakeLists.txt" "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\CMakeLists.txt"
copy "%RECIPE_DIR%\patches\tlib-CMakeLists.txt" "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\tlib\CMakeLists.txt"

rem Set execute permissions (not strictly necessary on Windows)
rem but keeping it for consistency with the bash script
attrib +x build.sh tools\building\check_weak_implementations.sh

rem Build the translation libraries
call bash -lc 'build.sh --tlib-only --net --no-gui'

rem Install procedure into a conda path that renode-cli can retrieve
set "ROOT_PATH=%~dp0.."
set "CONFIGURATION=Release"
set "CORES_PATH=%ROOT_PATH%src\Infrastructure\src\Emulator\Cores"
set "CORES_BIN_PATH=%CORES_PATH%\bin\%CONFIGURATION%"

mkdir "%PREFIX%\Library\lib\%PKG_NAME%"
tar -c -C "%CORES_BIN_PATH%\lib" . | tar -x -C "%PREFIX%\Library\lib\%PKG_NAME%"

endlocal
bash -lc "./conda_build.sh"
