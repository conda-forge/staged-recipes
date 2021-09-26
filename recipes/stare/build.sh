#!/bin/bash

cmake ${CMAKE_ARGS} -S $SRC_DIR \
      -DBUILD_SHARED_LIBS=YES \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DSTARE_INSTALL_LIBDIR=lib

make -j${CPU_COUNT}
make test
make install

 



