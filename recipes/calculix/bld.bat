cd ccx*/src

rm Makefile_MT
CP %RECIPE_DIR%\Makefile_MT Makefile_MT
CP %BUILD_PREFIX%\Library\mingw-w64\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make

FOR /F "delims=" %%i IN ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX=%%i"

make -f Makefile_MT ^
    SPOOLES_INCLUDE_DIR="%LIBRARY_PREFIX%/mingw-w64/include/spooles" ^
    SPOOLES_LIB_DIR="LIBRARY_PREFIX%/mingw-w64/lib"

cp ccx_*_MT $PREFIX/bin/ccx
cd $SRC_DIR
