#!/bin/bash

mkdir -p build
pushd build

# configure
${SRC_DIR}/configure \
	--prefix=${PREFIX} \
	--with-crypto-lib=openssl \
	--with-openssl-prefix=${PREFIX}

# build
make -j ${CPU_COUNT}

# check
make -j ${CPU_COUNT} check

# install
make install
