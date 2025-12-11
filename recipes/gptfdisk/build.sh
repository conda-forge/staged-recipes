#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make \
    CXX=${CXX} \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CGDISK_LDLIBS="-lncurses" \
    FATBINFLAGS= \
    THINBINFLAGS=

mkdir -p ${PREFIX}/bin
install -m 755 cgdisk ${PREFIX}/bin
install -m 755 fixparts ${PREFIX}/bin
install -m 755 gdisk ${PREFIX}/bin
install -m 755 sgdisk ${PREFIX}/bin
