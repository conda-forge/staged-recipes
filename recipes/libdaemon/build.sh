#!/bin/bash

set -ex

mkdir -pv _build
pushd _build

# configure
${SRC_DIR}/configure \
	--prefix=${PREFIX} \
;

# build
make -j ${CPU_COUNT}

# test
make -j ${CPU_COUNT} check

# install
make -j ${CPU_COUNT} install
