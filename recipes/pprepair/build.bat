@echo on
cmake -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
cmake --build build --parallel
if errorlevel 1 exit 1
ctest --test-dir build --output-on-failure
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1
