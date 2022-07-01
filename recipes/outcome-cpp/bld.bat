pushd quickcpplib
cmake -DCMAKE_INSTALL_PREFIX=%CD%\_install ^
  -B _build -G Ninja -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1
cmake --build _build
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1
popd

cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -B _build -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ^
  -Dquickcpplib_DIR=%CD%\quickcpplib\_install\lib\cmake\quickcpplib
if errorlevel 1 exit 1
cmake --build _build
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1
