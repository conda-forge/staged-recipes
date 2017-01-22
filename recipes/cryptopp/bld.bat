mkdir build
cd build
cmake -G "NMake Makefiles" -D BUILD_SHARED=OFF -D BUILD_TESTING=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
