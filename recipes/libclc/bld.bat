mkdir build
cd build
cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_MODULE_PATH=%LIBRARY_LIB%\\cmake\\llvm ^
  ..

ninja -j%CPU_COUNT%
ninja install
