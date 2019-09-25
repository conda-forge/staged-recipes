#!/bin/bash

# configure
mkdir -p _build
pushd _build
${SRC_DIR}/configure \
	--prefix=${PREFIX}

# build
make -j ${CPU_COUNT}

# check
make -j ${CPU_COUNT} check NO_EXTERNAL_NET=1

# install
make -j ${CPU_COUNT} install
