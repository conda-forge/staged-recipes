#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# set missing flags
export CFLAGS="-D_POSIX_C_SOURCE=199309L -DM_PI=3.14159265358979323846 ${CFLAGS}"
if  [[ "$(uname)" == "Darwin" ]]; then
	# required for TCP_KEEPALIVE
	export CFLAGS="-D_DARWIN_C_SOURCE ${CFLAGS}"
fi

# configure
${SRC_DIR}/configure \
	--disable-dmtviewer \
	--disable-dtt \
	--disable-monitors \
	--disable-online \
	--disable-only-dtt \
	--disable-static \
	--disable-silent-rules \
	--enable-dmt-runtime \
	--enable-online \
	--includedir=${PREFIX}/include/gds \
	--prefix="${PREFIX}" \
	--without-sasl \
;

# build
#export CPU_COUNT=1
make -j ${CPU_COUNT} V=1 VERBOSE=1

# check
make -j ${CPU_COUNT} V=1 VERBOSE=1 check
