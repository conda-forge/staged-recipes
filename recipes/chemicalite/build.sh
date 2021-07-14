cmake \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D CMAKE_INSTALL_LIBDIR=lib \
    -D CMAKE_BUILD_TYPE=Release \
    $SRC_DIR

make

LD_LIBRARY_PATH=$PWD/src ctest --output-on-failure

make install
