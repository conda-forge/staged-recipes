mkdir build
dir build
cmake -G ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
