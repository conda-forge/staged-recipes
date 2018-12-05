cd ccx*/src

rm Makefile_MT
CP %RECIPE_DIR%\Makefile_MT Makefile_MT
CP %BUILD_PREFIX%\Library\mingw-w64\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make


REM this line translates the windows-paths to paths understandable for the mingw env
REM -m, --mixed           like --windows, but with regular slashes (C:/WINNT)
FOR /F "delims=\" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX=%%i"

make -f Makefile_MT ^
    SPOOLES_INCLUDE_DIR="%LIBRARY_PREFIX%/mingw-w64/include/spooles" ^
    LIB_DIR="%LIBRARY_PREFIX%/mingw-w64/lib"

REM adding .exe to make the file executable
cp ccx_*_MT "%LIBRARY_PREFIX%/bin/ccx.exe"
cd %SRC_DIR%
