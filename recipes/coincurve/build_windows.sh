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

rm -rf ./{coincurve.egg-info, libsecp256k1}

mv ./coincurve/_windows_libsecp256k1.py ./coincurve/_libsecp256k1.py
curl -sLO "https://github.com/bitcoin-core/secp256k1/archive/$COINCURVE_UPSTREAM_REF.tar.gz")
tar xzf "$COINCURVE_UPSTREAM_REF.tar.gz"
mv "secp256k1-$COINCURVE_UPSTREAM_REF" secp256k1

(cd secp256k1; build_dll; cp .libs/secp256k1-0.dll ../coincurve/libsecp256k1.dll)

