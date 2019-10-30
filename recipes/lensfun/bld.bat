mkdir build && cd build

set CMAKE_CONFIG="Release"
set PKG_CONFIG_PATH=%PREFIX%/lib/pkgconfig
set LD_LIBRARY_PATH=%PREFIX%/lib

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      ..
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
