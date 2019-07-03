mkdir -p build
cd build
cmake -LAH -G "Ninja"                                                     \
    -DCMAKE_BUILD_TYPE="Release"                                          \
    -DCMAKE_PREFIX_PATH=${PREFIX}                                         \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                      \
    ..
ninja install -v