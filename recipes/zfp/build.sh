#!/usr/bin/env bash
mkdir build
cd build
cmake -DBUILD_ZFPY=ON -DZFP_WITH_OPENMP=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install
