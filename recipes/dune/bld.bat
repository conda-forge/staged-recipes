@echo off
setlocal enabledelayedexpansion

:: Create conda_build.sh wrapper
echo # Conda/pixi activation wrapper                   > conda_build.sh
echo if [ -f "D:/Miniforge/etc/profile.d/conda.sh" ]; then  >> conda_build.sh
echo   source D:/Miniforge/etc/profile.d/conda.sh     >> conda_build.sh
echo   conda activate "${PREFIX}"                     >> conda_build.sh
echo   conda activate --stack "${BUILD_PREFIX}"       >> conda_build.sh
echo fi                                               >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

:: Convert paths
set "_PREFIX=!PREFIX:\=/!"
set "_BUILD_PREFIX=!BUILD_PREFIX:\=/!"
set "_SRC_DIR=!SRC_DIR:\=/!"
set "_RECIPE_DIR=!RECIPE_DIR:\=/!"

set "_PREFIX_=!_PREFIX!"
set "_BUILD_PREFIX_=!_BUILD_PREFIX!"
set _SRC_DIR_=%_SRC_DIR%

set "_PREFIX=!_PREFIX:C:=/c/!"
set "_BUILD_PREFIX=!_BUILD_PREFIX:C:=/c/!"
set "_SRC_DIR=!_SRC_DIR:C:=/c/!"
set "_RECIPE_DIR=!_RECIPE_DIR:C:=/c/!"

set "_PREFIX=!_PREFIX:D:=/d/!"
set "_BUILD_PREFIX=!_BUILD_PREFIX:D:=/d/!"
set "_SRC_DIR=!_SRC_DIR:D:=/d/!"
set "_RECIPE_DIR=!_RECIPE_DIR:D:=/d/!"

set "_PREFIX=!_PREFIX://=/!"
set "_BUILD_PREFIX=!_BUILD_PREFIX://=/!"
set "_SRC_DIR=!_SRC_DIR://=/!"
set "_RECIPE_DIR=!_RECIPE_DIR://=/!"

set PATH=%BUILD_PREFIX%\Library\bin;%PATH%
set MSYSTEM=MINGW64
set MSYS2_PATH_TYPE=inherit
set MSYS2_ARG_CONV_EXCL="*"
set CHERE_INVOKING=1

bash -lce "./conda_build.sh"
if errorlevel 1 exit 1
