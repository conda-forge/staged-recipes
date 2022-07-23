#!/usr/bin/env bash
set -ex

echo "**************** G E T F E M  B U I L D  S T A R T S  H E R E ****************"

#./autogen.sh
./configure --prefix=$PREFIX --enable-shared --with-pic --enable-python # --enable-octave
make -j $CPU_COUNT
make install
make check -j $CPU_COUNT

echo "**************** G E T F E M  B U I L D  E N D S  H E R E ****************"
