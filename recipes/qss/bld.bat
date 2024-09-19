@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DUNIT_TESTS=OFF ^
  -DBUILD_SAMPLES=OFF
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

cmake --build build --parallel --config Release --target install
if errorlevel 1 exit 1
