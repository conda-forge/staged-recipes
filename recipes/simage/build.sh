mkdir -p build
cd build


cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
      -DCMAKE_BUILD_TYPE="Release" \
      -DUSE_QT5=ON \
      ..

make -j${CPU_COUNT} install