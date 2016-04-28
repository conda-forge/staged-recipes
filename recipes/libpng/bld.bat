mkdir build
cd build

:: Configure.
cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D ZLIB_LIBRARY=%LIBRARY_LIB%\zlib.lib ^
      -D ZLIB_INCLUDE_DIR=%LIBRARY_INC% ^
      -D CMAKE_BUILD_TYPE=Release ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
nmake
if errorlevel 1 exit 1

:: Test.
ctest
if errorlevel 1 exit 1

:: Install.
nmake install
if errorlevel 1 exit 1

:: Make copies of the .lib files without the embedded version number.
copy %LIBRARY_LIB%\libpng16.lib %LIBRARY_LIB%\libpng.lib
if errorlevel 1 exit 1

copy %LIBRARY_LIB%\libpng16_static.lib %LIBRARY_LIB%\libpng_static.lib
if errorlevel 1 exit 1

copy %RECIPE_DIR%\libpng-LICENSE.txt %SRC_DIR%\libpng-LICENSE.txt
