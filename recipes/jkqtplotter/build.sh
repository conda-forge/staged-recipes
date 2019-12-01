mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DJKQtPlotter_BUILD_EXAMPLES=OFF \
    -DJKQtPlotter_BUILD_STATIC_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    ..
make -j${CPU_COUNT}
make install
