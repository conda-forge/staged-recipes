#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Use the libtool for now
export LIBTOOL="${BUILD_PREFIX}/bin/libtool"

make
make install "PREFIX=${PREFIX}"

# Only keep dynamic library
rm -rf "${PREFIX}/lib/libunibilium.a"
