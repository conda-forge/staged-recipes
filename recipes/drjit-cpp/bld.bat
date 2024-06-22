@echo on

cmake %SRC_DIR% ^
  -G "Ninja" ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DDRJIT_ENABLE_JIT=OFF ^
  -DDRJIT_ENABLE_AUTODIFF=OFF ^
  -DDRJIT_ENABLE_PYTHON=OFF ^
  -DDRJIT_ENABLE_TESTS=ON ^
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=ON

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release

cmake --build build --target install
