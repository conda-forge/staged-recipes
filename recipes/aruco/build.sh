mkdir -p build
cd build
cmake -LAH                                                                \
    -DCMAKE_BUILD_TYPE="Release"                                          \
    -DCMAKE_PREFIX_PATH=${PREFIX}                                         \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                      \
    ..
make install -j${CPU_COUNT}