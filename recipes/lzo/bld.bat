set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%

mkdir cmake-build
cd cmake-build

:: Configure.
cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D ENABLE_SHARED=ON ^
      -D ENABLE_STATIC=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
nmake
if errorlevel 1 exit 1

:: Test.
lzotest.exe -mlzo -n2 -q %SRC_DIR%/COPYING
if errorlevel 1 exit 1

:: Install.
nmake install
if errorlevel 1 exit 1
