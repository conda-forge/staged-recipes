@echo on

:: reset compiler to m2w64-toolchain since MSVC is also activated
:: (MSVC is needed later to generate the import lib)
set "CC=gcc.exe"

copy "%RECIPE_DIR%\build.sh" .
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
bash -lce "./build.sh"
if errorlevel 1 exit 1

:: Generate MSVC-compatible import library
FOR /F %%i in ("liquid*.dll") DO lib /def:liquid.def /name:%%~ni.dll /out:liquid.lib /machine:x64
copy liquid.lib "%LIBRARY_PREFIX%/lib/liquid.lib"
if errorlevel 1 exit 1
