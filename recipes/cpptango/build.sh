mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCPPZMQ_BASE=$PREFIX \
      -DIDL_BASE=$PREFIX \
      -DOMNI_BASE=$PREFIX \
      -DZMQ_BASE=$PREFIX \
      -DTANGO_JPEG_MMX=OFF \
      -DBUILD_TESTING=OFF \
      ..

make -j $CPU_COUNT
make install
