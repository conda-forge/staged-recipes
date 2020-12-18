cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DINJA_USE_EMBEDDED_JSON=OFF ^
      -DBUILD_TESTING=OFF ^
      -DINJA_BUILD_TESTS=OFF ^
      -DBUILD_BENCHMARK=OFF ^
      %SRC_DIR%

if errorlevel 1 exit 1

cmake --build . --target ALL_BUILD --config Release

if errorlevel 1 exit 1