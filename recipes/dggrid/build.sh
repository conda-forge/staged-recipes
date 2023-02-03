#!/bin/bash
set -e

mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=Release $SRC_DIR

# -DCMAKE_PREFIX_PATH=$PREFIX \
# -DCMAKE_INSTALL_PREFIX=$PREFIX \
# -DCMAKE_INSTALL_LIBDIR=lib \

make -j${CPU_COUNT}

# install?!
# cp ./src/apps/dggrid/dggrid /usr/bin/dggrid
install ./src/apps/dggrid/dggrid $PREFIX/bin/dggrid

