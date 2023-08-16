#/bin/bash

set -eox pipefail

build_dll() {
    # Prevent calling 'sh', which seems to drop-off the BASH framework on windows
    sed -i 's@#!/bin/sh@@' ./autogen.sh
    bash ./autogen.sh
    ./configure --enable-module-recovery --enable-experimental --enable-module-ecdh --enable-module-extrakeys --enable-module-schnorrsig --enable-benchmark=no --enable-tests=no --enable-openssl-tests=no --enable-exhaustive-tests=no --enable-static --disable-dependency-tracking --with-pic
    make
}

mkdir -p /tmp

# This may not be necessary to prevent corruption of SOURCES.txt with full-path
rm -rf coincurve.egg-info libsecp256k1

mv ${SRC_DIR}/coincurve/_windows_libsecp256k1.py ${SRC_DIR}/coincurve/_libsecp256k1.py

curl -sLO "https://github.com/bitcoin-core/secp256k1/archive/$COINCURVE_UPSTREAM_REF.tar.gz"
tar xzf "$COINCURVE_UPSTREAM_REF.tar.gz"
mv "secp256k1-$COINCURVE_UPSTREAM_REF" secp256k1

(cd secp256k1; build_dll; cp .libs/secp256k1-0.dll ../coincurve/libsecp256k1.dll)

