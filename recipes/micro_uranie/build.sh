#!/bin/bash
set -x

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ${SRC_DIR}/uranie-source
cmake --build . --target install -j $(nproc)
ctest -V -j $(($(nproc)/2)) -R UranieDataServer
