mkdir build
cd build

cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_BUILD_TYPE=Release ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1
:: No "make check" available
nmake install
if errorlevel 1 exit 1
