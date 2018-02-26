#!/bin/bash
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release .. -DOPTION_BUILD_SHARED_LIBS=yes -DCMAKE_INSTALL_LIBDIR=lib
make -j${CPU_COUNT}
make test && make install
