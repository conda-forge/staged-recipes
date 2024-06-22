@echo on

cmake %SRC_DIR% ^
  -G "Ninja" ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DFX_GLTF_USE_INSTALLED_DEPS=ON

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release

cmake --build build --target install
