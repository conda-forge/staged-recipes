set "CXXFLAGS= -MD"
set
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ..
if errorlevel 1 exit 1
cmake --build . --config Release
if errorlevel 1 exit 1
echo "Build finished"
cmake --build . --target install
if errorlevel 1 exit 1
