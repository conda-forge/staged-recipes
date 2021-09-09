#!/bin/bash

cmake -S $SRC_DIR \
      -DBUILD_SHARED_LIBS=YES \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DSTARE_INSTALL_LIBDIR=lib

make
make test
make install

 



