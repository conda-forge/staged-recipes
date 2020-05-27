

mkdir build
cd build

cmake -LAH                             \
    -DCMAKE_PREFIX_PATH=${PREFIX}      \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}   \
    ..

make -j${CPU_COUNT}
make install
