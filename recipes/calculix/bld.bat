cd ccx*/src

rm Makefile_MT
CP %RECIPE_DIR%\Makefile_MT Makefile_MT
CP %BUILD_PREFIX%\Library\mingw-w64\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make

FOR /F "delims=\" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX=%%i"

echo "------------------------"
echo %LIBRARY_PREFIX%
echo "------------------------"

make -f Makefile_MT ^
    SPOOLES_INCLUDE_DIR="%LIBRARY_PREFIX%/mingw-w64/include/spooles" ^
    LIB_DIR="%LIBRARY_PREFIX%/mingw-w64/lib" ^
    FORTRAN_COMPILER="gfortran"

cp ccx_*_MT "%LIBRARY_PREFIX%/bin/ccx"
cd %SRC_DIR%
