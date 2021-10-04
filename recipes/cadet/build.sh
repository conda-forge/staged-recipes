mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_CADET_MEX=OFF \
    -DBLA_VENDOR=Intel10_64lp_seq \
    ..
make install -j $CPU_COUNT
