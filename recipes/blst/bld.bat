echo source %SYS_PREFIX:\=/%/etc/profile.d/conda.sh    > conda_build.sh
echo conda activate "${PREFIX}"                       >> conda_build.sh
echo conda activate --stack "${BUILD_PREFIX}"         >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

set PREFIX=%PREFIX:\=/%
set BUILD_PREFIX=%BUILD_PREFIX:\=/%
set CONDA_PREFIX=%CONDA_PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "./conda_build.sh"
if errorlevel 1 exit 1

:: @echo off

:: set CC=gcc
:: :: set "AS=nasm -f win64"
:: :: set "AS=llvm-ml -m64 --assemble /c"
:: set "AS=ml64 /nologo /c /Cp /Cx /Zi"
:: :: mkdir %SRC_DIR%\build\win64_llvm
:: :: call powershell -File %RECIPE_DIR%\helpers\masm_llvm.ps1 -ASM_DIR %SRC_DIR%\build\win64 -OUTPUT_DIR %SRC_DIR%\build\win64_llvm
:: :: dir %SRC_DIR%\build\win64_llvm
:: call build.bat -shared
:: if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
::
:: mkdir "%PREFIX%\Library\lib"
:: copy blst-%PKG_MAJOR_VERSION%.dll %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.dll
:: copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.lib
:: copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst.lib
::
:: copy blst.h %PREFIX%\Library\include\blst.h
:: copy blst_aux.h %PREFIX%\Library\include\blst/blst_aux.h
::
:: pushd %SRC_DIR%\bindings\python
::   set CXX=g++
::   type run.me
::   %PYTHON% run.me
:: popd
