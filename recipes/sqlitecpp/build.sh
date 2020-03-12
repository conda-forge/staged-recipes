#!/bin/sh

mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_LIBDIR=lib \
	  -DSQLITECPP_INTERNAL_SQLITE=OFF \
	  -DSQLITECPP_BUILD_TESTS=ON \
	  -DBUILD_SHARED_LIBS=ON \
      $SRC_DIR

make VERBOSE=1 -j${CPU_COUNT}
make test
make install