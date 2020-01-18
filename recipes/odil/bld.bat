mkdir build
cd build

cmake ^
  -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBOOST_UUID_FORCE_AUTO_LINK=ON ^
  -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF ^
  -DWITH_DCMTK=OFF ^
  -DBUILD_PYTHON_WRAPPERS=ON -DBUILD_JAVASCRIPT_WRAPPERS=OFF ^
  -DCMAKE_INSTALL_PREFIX=%PREFIX% -DPYTHON_EXECUTABLE=%PYTHON% ^
  ../
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
