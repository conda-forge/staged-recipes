mkdir -p build
cd build

cmake -G "Ninja" \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib \
      -D CMAKE_BUILD_TYPE="Release" \
      -D USE_QT5=ON \
      ..

make -j${CPU_COUNT} install