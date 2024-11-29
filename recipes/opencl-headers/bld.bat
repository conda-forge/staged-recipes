cmake -G Ninja %CMAKE_ARGS% .
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

ctest
if errorlevel 1 exit 1

mkdir %LIBRARY_PREFIX%\lib\pkgconfig
MOVE %LIBRARY_PREFIX%\share\pkgconfig\OpenCL-Headers.pc %LIBRARY_PREFIX%\lib\pkgconfig\OpenCL-Headers.pc
if errorlevel 1 exit 1
