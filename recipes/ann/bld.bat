mkdir -p build-cmake
cd build-cmake
cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
MOVE %LIBRARY_LIB%\ann.dll %LIBRARY_BIN%
