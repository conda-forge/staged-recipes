#!/bin/bash
mkdir build
cd build

# -lrt to help a test program link

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS -Wl,--no-as-needed -lrt" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SHARED_LIBS=ON \
      -DIMATH_LIB_SUFFIX="" \
      ..

make -j${CPU_COUNT}
make install