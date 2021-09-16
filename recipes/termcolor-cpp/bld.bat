mkdir build
cd build

cmake -G "NMake Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %CMAKE_ARGS% ..
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1