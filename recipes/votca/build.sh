#!/bin/bash
mkdir build
cd build
cmake -DBUILD_XTP=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
cmake --parallel ${NUM_CPUS}
cmake --target install
