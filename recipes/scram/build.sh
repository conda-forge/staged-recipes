mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DBUILD_GUI=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DINSTALL_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j$CPU_COUNT
make install
