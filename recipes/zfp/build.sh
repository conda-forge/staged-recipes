mkdir build
cd build
cmake -LAH \
    -DCMAKE_BUILD_TYPE="Release"             \
    -DCMAKE_PREFIX_PATH=${PREFIX}            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}         \
    -DBUILD_ZFPY=ON                          \
    -DBUILD_UTILITIES=ON                     \
    ..

make -j ${CPU_COUNT}
make install
