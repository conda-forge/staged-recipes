:: @echo off

set CC=gcc
:: set "AS=nasm -f win64"
set "AS=llvm-ml64 /c /Cp /Cx /Zi"
mkdir %SRC_DIR%\build\win64_nasm
:: call powershell -File %RECIPE_DIR%\helpers\masm_nasm.ps1 -ASM_DIR %SRC_DIR%\build\win64 -OUTPUT_DIR %SRC_DIR%\build\win64_nasm
call build.bat -shared
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

mkdir "%PREFIX%\Library\lib"
copy blst-%PKG_MAJOR_VERSION%.dll %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.dll
copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.lib
copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst.lib

copy blst.h %PREFIX%\Library\include\blst.h
copy blst_aux.h %PREFIX%\Library\include\blst/blst_aux.h

pushd %SRC_DIR%\bindings\python
  set CXX=g++
  type run.me
  %PYTHON% run.me
popd
