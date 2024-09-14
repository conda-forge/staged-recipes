@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DSIGSLOT_COMPILE_EXAMPLES=OFF ^
  -DSIGSLOT_COMPILE_TESTS=OFF ^
  -DSIGSLOT_REDUCE_COMPILE_TIME=OFF ^
  -DSIGSLOT_ENABLE_INSTALL=ON
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure --build-config Release
if errorlevel 1 exit 1

cmake --build build --parallel --config Release --target install
if errorlevel 1 exit 1
