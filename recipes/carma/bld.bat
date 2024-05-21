rem setlocal EnableDelayedExpansion

mkdir build
cd build

cmake -G "NMake Makefiles" ^
      %CMAKE_ARGS% ^
      -DCARMA_INSTALL_LIB:BOOL=ON ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
