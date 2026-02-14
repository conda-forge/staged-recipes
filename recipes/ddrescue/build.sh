#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

tar --lzip --extract --verbose --file=ddrescue-${PKG_VERSION}.tar.lz
cd ${SRC_DIR}/ddrescue-${PKG_VERSION}

./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}

make check \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}"
make install \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}"
