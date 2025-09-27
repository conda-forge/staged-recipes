#!/bin/bash

cmake -B build -S . \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build --target install -- -j${CPU_COUNT}
