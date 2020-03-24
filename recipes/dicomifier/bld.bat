mkdir build
cd build

cmake ^
  -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF ^
  -DCMAKE_INSTALL_PREFIX=%PREFIX% -DPYTHON_EXECUTABLE=%PYTHON% ^
  ../
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
