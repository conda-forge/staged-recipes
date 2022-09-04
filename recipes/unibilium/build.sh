#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Use the libtool for now
export LIBTOOL=${BUILD_PREFIX}/bin/libtool
make

# Install it to the prefix
make install "DESTDIR=${PREFIX}"

# Remove the static library
# so that we only keep the dynamic library
rm -rf "${PREFIX}/usr/local/lib/libunibilium.a"
