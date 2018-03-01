mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DSIMAGE_RUNTIME_LINKING=ON \
      -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
      ..

make -j${CPU_COUNT} install