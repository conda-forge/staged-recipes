mkdir build && cd build

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -D CMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      ..
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
