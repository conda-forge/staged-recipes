#!/bin/bash


mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -GNinja ..
ninja install
