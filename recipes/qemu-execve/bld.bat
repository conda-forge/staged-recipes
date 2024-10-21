:: @echo off
:: setlocal enabledelayedexpansion
::
:: set "PS_SCRIPT=%RECIPE_DIR%\helpers\_build_qemu.ps1"
::
:: powershell -NoProfile -ExecutionPolicy Bypass -Command ^
::     "& '%PS_SCRIPT%' " ^
::     > build_qemu_output.log 2>&1
::
:: if %ERRORLEVEL% neq 0 (
::     echo Error occurred during QEMU build. Check build_qemu_output.log for details.
::     type build_qemu_output.log
::     exit /b %ERRORLEVEL%
:: )
::
:: echo QEMU build log:
:: echo QEMU build completed successfully.

echo source %SYS_PREFIX:\=/%/etc/profile.d/conda.sh    > conda_build.sh
echo conda activate "${PREFIX}"                       >> conda_build.sh
echo conda activate --stack "${BUILD_PREFIX}"         >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

set PREFIX=%PREFIX:\=/%
set BUILD_PREFIX=%BUILD_PREFIX:\=/%
set CONDA_PREFIX=%CONDA_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set RECIPE_DIR=%RECIPE_DIR:\=/%
set PYTHON=%PYTHON:\=/%
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
set build_platform=win-64
set target_platform=win-64
bash -lc "./conda_build.sh"
if errorlevel 1 exit 1