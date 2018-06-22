setlocal EnableDelayedExpansion

:: Make build directory
mkdir build
cd build

:: Specify location of TBB
set "TBB_ROOT=%LIBRARY_PREFIX%"

:: Configure
cmake ../ ^
      -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DEMBREE_TUTORIALS=OFF ^
      -DEMBREE_MAX_ISA="AVX2" ^
      -DEMBREE_ISPC_SUPPORT=OFF
if errorlevel 1 exit 1

:: Compile
nmake
if errorlevel 1 exit 1

:: embree lacks unit tests

nmake install
if errorlevel 1 exit 1

:: remove tutorial models (which embree installed even when EMBREE_TUTORIALS=off)
:: this is easier than patching embree's cmake
rd /s /q %LIBRARY_PREFIX%/bin/models
if errorlevel 1 exit 1
