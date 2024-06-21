@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release

cmake --build build --target install --config Release
