#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

mkdir -p build
cd build

cmake -LAH \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -Dmomentum:STRING=GEV -Dlength:STRING=MM \
    ../source 


make -j${CPU_COUNT}

make test

make install
