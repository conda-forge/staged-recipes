#!/bin/bash

mkdir build
cd build

cmake ../CLHEP/ -DCMAKE_INSTALL_PREFIX=${PREFIX}

make -j ${CPU_COUNT}
make test
make install

