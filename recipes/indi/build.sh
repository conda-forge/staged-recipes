mkdir -p build/libindi
cd build/libindi
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DINDI_BUILD_DRIVERS=OFF \
    ../../libindi
make
make install
