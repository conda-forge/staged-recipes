#!/bin/bash
set -euxo pipefail
rm -rf build || true
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
make install -j$CPU_COUNT
