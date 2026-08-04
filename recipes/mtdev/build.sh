#!/bin/bash

set -euxo pipefail

./configure \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --build="${BUILD}" \
  --host="${HOST}" \
  --disable-static \
  --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install -j"${CPU_COUNT}"

# conda-forge does not ship libtool archives; they hardcode build paths.
rm -f "${PREFIX}"/lib/*.la
