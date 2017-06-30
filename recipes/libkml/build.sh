mkdir build && cd build
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      $SRC_DIR
ctest
make install -j $CPU_COUNT
