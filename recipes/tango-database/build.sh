mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_VERBOSE_MAKEFILE=true \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DMYSQL_INCLUDE_DIR=$PREFIX/include/mysql \
      ..

make -j $CPU_COUNT
make install
