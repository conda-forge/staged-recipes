set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%/Library"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
copy "%RECIPE_DIR%\build_wasmer.sh" .
bash -lce "%SRC_DIR%/build_wasmer.sh"
if errorlevel 1 exit 1
