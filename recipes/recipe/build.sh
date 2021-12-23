#!/bin/bash
set -ex

cmake -H. -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build build --target install
