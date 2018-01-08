#!/bin/bash

mkdir build
cd build

cmake ../CLHEP/ -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib" -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}

make -j ${CPU_COUNT}
make test
make install

