@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DENTT_BUILD_LIB=ON ^
  -DENTT_BUILD_TESTING=ON
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure --build-config Release
if errorlevel 1 exit 1

cmake --build build --parallel --config Release --target install
if errorlevel 1 exit 1
