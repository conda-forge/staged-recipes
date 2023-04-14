cmake -G "NMake Makefiles"                      ^ 
      -B build/                                 ^
      -D EVALHYD_BUILD_TEST=OFF                 ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
      -D CMAKE_INSTALL_LIBDIR=lib               ^ 
      -D CMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

cmake --build build/ --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build/ --prefix %LIBRARY_PREFIX%
if errorlevel 1 exit 1
