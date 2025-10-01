mkdir -p build
cd build
cmake ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DFTXUI_ENABLE_INSTALL=ON \
      ..
make -j${CPU_COUNT}
make install
