mkdir build && cd build

cmake -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CMAKE_BUILD_TYPE=Release \
      $SRC_DIR

make
make install
