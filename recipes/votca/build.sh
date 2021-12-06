#!/bin/bash
mkdir build
cd build
cmake -DBUILD_XTP=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} -DINJECT_MARCH_NATIVE=OFF ..
make  # -j${NUM_CPUS}
make install
