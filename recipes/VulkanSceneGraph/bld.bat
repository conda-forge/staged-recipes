@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%

cmake --build build --parallel --config Release

cmake --install build --config Release
