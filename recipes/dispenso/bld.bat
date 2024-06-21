@echo on

cmake %SRC_DIR% ^
  -G "Ninja" ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DDISPENSO_BUILD_TESTS=ON

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release -LE flaky

cmake --build build --target install
