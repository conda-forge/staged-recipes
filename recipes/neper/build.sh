#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE='Release' -DHAVE_LIBSCOTCH:BOOL=ON ../src

make -j ${CPU_COUNT}
make install
