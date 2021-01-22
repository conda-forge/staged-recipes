#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cmake -B build -S "${SRC_DIR}" \
	-D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON \
	-D BOOST=OFF -D CMAKE_INSTALL_PREFIX="${PREFIX}"
cd build
make -j${CPU_COUNT} libsoplex libsoplex-pic
make install
