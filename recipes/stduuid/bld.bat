rmdir /Q /S build
mkdir build
cd build 
cmake ${CMAKE_ARGS} -GNinja CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DUUID_BUILD_TESTS=OFF -S .. -B .
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
