#!/bin/bash
mkdir build
cd build
cmake -DBUILD_XTP=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib -DINJECT_MARCH_NATIVE=OFF ..
make  # -j${NUM_CPUS}
make check
make install
