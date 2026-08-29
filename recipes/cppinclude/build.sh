#!/bin/bash

cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build --target install -- -j${CPU_COUNT}
