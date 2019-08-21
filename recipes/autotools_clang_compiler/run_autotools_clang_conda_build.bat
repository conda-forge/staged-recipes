copy "%RECIPE_DIR%\build.sh" .
copy "%BUILD_PREFIX%\Library\bin\conda_build_wrapper.sh" .
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
bash -lce "./conda_build_wrapper.sh"
if errorlevel 1 exit 1

