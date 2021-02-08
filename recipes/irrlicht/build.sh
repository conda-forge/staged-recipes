#!/bin/sh
echo "This is src dir SRC_DIR"
echo "This is CXXFLAGS: $CXXFLAGS"

mkdir build && cd build

# GNU extensions are required by Irrlicht
CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++/-std=gnu++/g")

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      $SRC_DIR

VERBOSE=1 make -j${CPU_COUNT}
make install
