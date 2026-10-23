#!/bin/bash

set -euxo pipefail

# The libyal sub-libraries libpff depends on (libcerror, libbfio, libuna,
# ...) ship as local copies in the tarball and are linked in statically, which
# is how libyal intends them to be consumed. Nothing else uses them.
./configure \
    --prefix="${PREFIX}" \
    --host="${HOST}" \
    --build="${BUILD}" \
    --enable-shared \
    --disable-static \
    --disable-nls \
    --disable-python

make -j"${CPU_COUNT}"
make install

rm -f "${PREFIX}/lib/libpff.la"
