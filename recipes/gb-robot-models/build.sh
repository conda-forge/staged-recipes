#!/bin/bash -e
cmake -G Ninja -S ${SRC_DIR} -B build -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build --parallel ${CPU_COUNT} --target install
