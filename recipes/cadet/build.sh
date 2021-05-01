mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_CADET_MEX=OFF \
    ..
make install -j $CPU_COUNT
