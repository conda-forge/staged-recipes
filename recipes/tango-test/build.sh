mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_VERBOSE_MAKEFILE=true \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      ..

make -j $CPU_COUNT
make install
