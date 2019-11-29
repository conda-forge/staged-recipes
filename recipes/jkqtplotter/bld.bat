mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ..
if errorlevel 1 exit 1
cmake --build . --config Release --target install
if errorlevel 1 exit 1
