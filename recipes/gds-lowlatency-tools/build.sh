#!/bin/bash

set -e

mkdir -p _build
cd _build

# configure
${SRC_DIR}/configure \
	--includedir=${PREFIX}/include/gds \
	--prefix=${PREFIX} \
;

# build
make -j ${CPU_COUNT} VERBOSE=1 V=1

# test
make -j ${CPU_COUNT} VERBOSE=1 V=1 check

# install
make -j ${CPU_COUNT} VERBOSE=1 V=1 install
