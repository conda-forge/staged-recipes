#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i

# Required to make linker look in correct prefix
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --help

./configure \
    --prefix=$PREFIX \
    --disable-download \
    --enable-summary \
    --disable-static \

make -j $CPU_COUNT

make -j $CPU_COUNT check

make install

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
