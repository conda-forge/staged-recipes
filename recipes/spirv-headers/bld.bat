mkdir build
cd build
cmake -GNinja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  ..

ninja -j%CPU_COUNT%
ninja install
