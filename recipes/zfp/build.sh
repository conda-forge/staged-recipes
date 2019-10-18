#!/bin/bash
set -e

mkdir build
cd build
cmake -DBUILD_ZFPY=ON -DZFP_WITH_OPENMP=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make test
make install

./bin/testzfp
