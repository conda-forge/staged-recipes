#!/bin/bash
set -e

mkdir build
cd build
cmake -DBUILD_ZFPY=ON -DZFP_WITH_OPENMP=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib ..
make -j${CPU_COUNT}
make test
make install

./bin/testzfp
