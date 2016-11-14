#!/bin/bash
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ./cmake
make -j4
make install