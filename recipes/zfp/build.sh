#!/usr/bin/env bash
mkdir build
cd build
cmake -DBUILD_ZFPY=ON -DBUILD_TESTING=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install
