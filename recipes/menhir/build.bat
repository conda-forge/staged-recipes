@echo off
setlocal enabledelayedexpansion

:: Create conda_build.sh wrapper
:: With pixi, environment is already activated - no need to source conda.sh
:: With Miniforge/conda, we need to source conda.sh and activate
echo # Conda/pixi activation wrapper                   > conda_build.sh
echo if [ -f "D:/Miniforge/etc/profile.d/conda.sh" ]; then  >> conda_build.sh
echo   source D:/Miniforge/etc/profile.d/conda.sh     >> conda_build.sh
echo   conda activate "${PREFIX}"                     >> conda_build.sh
echo   conda activate --stack "${BUILD_PREFIX}"       >> conda_build.sh
echo fi                                               >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

:: Convert backslashes using delayed expansion to avoid issues with unexpanded %VAR% placeholders
set "_PREFIX=!PREFIX:\=/!"
set "_BUILD_PREFIX=!BUILD_PREFIX:\=/!"
set "_SRC_DIR=!SRC_DIR:\=/!"
set "_RECIPE_DIR=!RECIPE_DIR:\=/!"

:: Store mixed C: with unix / (Windows-compatible format for GHC settings)
:: These are exported to bash for use in patching GHC settings files
set "_PREFIX_=!_PREFIX!"
set "_BUILD_PREFIX_=!_BUILD_PREFIX!"
set _SRC_DIR_=%_SRC_DIR%

:: Convert C: and D: to /c, /d (Unix-style for bash/configure)
set "_PREFIX=!_PREFIX:C:=/c/!"
set "_BUILD_PREFIX=!_BUILD_PREFIX:C:=/c/!"
set "_SRC_DIR=!_SRC_DIR:C:=/c/!"
set "_RECIPE_DIR=!_RECIPE_DIR:C:=/c/!"

set "_PREFIX=!_PREFIX:D:=/d/!"
set "_BUILD_PREFIX=!_BUILD_PREFIX:D:=/d/!"
set "_SRC_DIR=!_SRC_DIR:D:=/d/!"
set "_RECIPE_DIR=!_RECIPE_DIR:D:=/d/!"

:: Clean up double slashes
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
