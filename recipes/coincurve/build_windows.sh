#/bin/bash

set -eox pipefail

build_dll() {
    # Prevent calling 'sh', which seems to drop-off the BASH framework on windows
    sed -i 's@#!/bin/sh@@' ./autogen.sh
    bash ./autogen.sh
    ./configure --disable-dependency-tracking \
                --enable-benchmark=no \
                --enable-experimental \
                --enable-exhaustive-tests=no \
                --enable-module-recovery \
                --enable-module-ecdh \
                --enable-module-extrakeys \
                --enable-module-schnorrsig \
                --enable-static \
                --enable-tests=no \
                --with-pic
    make
    make check
}

mkdir -p /tmp

rm -rf ${SRC_DIR}/{coincurve.egg-info, libsecp256k1}

mv ${SRC_DIR}/coincurve/_windows_libsecp256k1.py ${SRC_DIR}/coincurve/_libsecp256k1.py

(cd ${SRC_DIR}; curl -sLO "https://github.com/bitcoin-core/secp256k1/archive/$COINCURVE_UPSTREAM_REF.tar.gz")
(cd ${SRC_DIR}; tar xzf "$COINCURVE_UPSTREAM_REF.tar.gz")
(cd ${SRC_DIR}; mv "secp256k1-$COINCURVE_UPSTREAM_REF" secp256k1)

(cd ${SRC_DIR}/secp256k1; build_dll; cp .libs/secp256k1-0.dll ${SRC_DIR}/coincurve/libsecp256k1.dll)

